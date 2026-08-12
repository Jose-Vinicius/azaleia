module Ai
  class TaskAnalysisService
    def self.call(user, period_days: 30)
      days = [ 7, 30, 90, 365 ].include?(period_days.to_i) ? period_days.to_i : 30
      start_date = days.days.ago.beginning_of_day
      end_date = Time.current.end_of_day

      completed_tasks = user.tasks.where(completed: true, completed_at: start_date..end_date)
      pending_tasks = user.tasks.where(completed: [ nil, false ])
      time_logged = TimeEntry.joins(:task)
                            .where(tasks: { user_id: user.id })
                            .where(created_at: start_date..end_date)
                            .sum(:duration_minutes)

      delayed_tasks = user.tasks.where("schedule_at < ?", Time.current).where(completed: [ nil, false ]).count

      multiplier_counts = completed_tasks.joins(:multiplier).group("multipliers.name").count

      eqi_summary = if user.eqi_profile
                      "Total EQ: #{user.eqi_profile.total_eq}, Subescalas com atenção (<85): #{user.low_eqi_subscales.map { |s| s.sub('_score', '') }.join(', ').presence || 'Nenhuma'}"
      else
                      "Perfil EQ-i 2.0 ainda não cadastrado."
      end

      mbti_summary = if user.mbti_profile
                       "MBTI: #{user.mbti_profile.final_type} (#{user.mbti_profile.temperament_group}), Função Dominante: #{user.mbti_profile.dominant_function}, Auxiliar: #{user.mbti_profile.auxiliary_function}"
      else
                       "Perfil MBTI ainda não cadastrado."
      end

      system_instruction = <<~SYS
        Você é um especialista sênior em produtividade, psicometria (EQ-i 2.0 e MBTI) e gestão de tempo do sistema Azaleia.
        Sua tarefa é analisar o desempenho de tarefas e tempo do usuário no período selecionado e fornecer um relatório diagnóstico motivador, prático e fundamentado.
        Responda em português do Brasil usando formatação Markdown rica e estruturada.
      SYS

      prompt = <<~PROMPT
        Período de Análise: Últimos #{days} dias (Período: #{start_date.strftime('%d/%m/%Y')} até #{end_date.strftime('%d/%m/%Y')})

        DADOS DE PRODUTIVIDADE E TAREFAS:
        - Tarefas Concluídas no Período: #{completed_tasks.count}
        - Tarefas Pendentes/Em Andamento: #{pending_tasks.count}
        - Tarefas Atrasadas Atualmente: #{delayed_tasks}
        - Tempo Total Registrado (minutos): #{time_logged} mins (#{(time_logged / 60.0).round(1)}h)
        - Distribuição por Importância: #{multiplier_counts.inspect}
        - Metas Ativas Cadastradas: #{user.goals.active.count}

        DADOS PSICOMÉTRICOS DO USUÁRIO:
        - Inteligência Emocional (Ametista): #{eqi_summary}
        - Perfil de Personalidade (Bismuto): #{mbti_summary}

        Por favor, estruture sua resposta no seguinte formato Markdown:
        ### 📊 Visão Geral da Produtividade
        (Resumo sintético do ritmo de trabalho no período)

        ### 🧠 Cruzamento Psicométrico & Comportamento
        (Como o perfil de inteligência emocional e MBTI afetam a execução e o foco no período)

        ### ⚠️ Gargalos e Pontos de Atenção
        (Análise de tarefas atrasadas, sobrecarga ou desequilíbrio de prioridades)

        ### 🎯 3 Recomendações Práticas para o Próximo Período
        (Ações concretas e imediatas para otimizar os resultados)
      PROMPT

      GeminiClient.generate_content(prompt, system_instruction: system_instruction)
    end
  end
end
