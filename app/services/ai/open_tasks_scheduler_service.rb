module Ai
  class OpenTasksSchedulerService
    def self.suggest(user)
      open_tasks = user.tasks.where(completed: [nil, false])
                             .where("schedule_at IS NULL OR schedule_at < ?", Time.current)
                             .includes(:multiplier, :project, :goal)

      if open_tasks.empty?
        return {
          "summary" => "Não foram encontradas tarefas em aberto sem agendamento ou atrasadas no momento. Excelente organização!",
          "suggestions" => []
        }
      end

      upcoming_tasks = user.tasks.where(completed: [nil, false])
                                 .where("schedule_at >= ?", Time.current)
                                 .order(schedule_at: :asc)
                                 .limit(20)

      eqi_summary = if user.eqi_profile
                      "EQ Total: #{user.eqi_profile.total_eq}, Subescalas em atenção: #{user.low_eqi_subscales.map { |s| s.sub('_score', '') }.join(', ').presence || 'Nenhuma'}"
                    else
                      "EQ-i não cadastrado"
                    end

      mbti_summary = if user.mbti_profile
                       "MBTI: #{user.mbti_profile.final_type} (#{user.mbti_profile.temperament_group})"
                     else
                       "MBTI não cadastrado"
                     end

      now = Time.current
      current_time_info = "#{now.strftime('%d/%m/%Y %H:%M')} (#{now.strftime('%A')})"

      tasks_payload = open_tasks.map do |t|
        status_info = if t.schedule_at.nil?
                        "Sem agendamento prévio"
                      else
                        "Atrasada (estava para #{t.schedule_at.strftime('%d/%m/%Y %H:%M')})"
                      end

        mult_name = t.multiplier&.name || "Padrão"
        goal_title = t.goal&.title || t.project&.name || "Nenhum"

        "- ID #{t.id}: '#{t.title}' | Duração: #{t.estimated_minutes || 30} min | Importância: #{mult_name} | Vínculo: #{goal_title} | Status: #{status_info}"
      end.join("\n")

      scheduled_payload = if upcoming_tasks.any?
                            upcoming_tasks.map do |t|
                              "- ID #{t.id}: '#{t.title}' agendada para #{t.schedule_at.strftime('%d/%m/%Y %H:%M')} (#{t.estimated_minutes || 30} min)"
                            end.join("\n")
                          else
                            "Nenhuma tarefa agendada para os próximos dias."
                          end

      system_instruction = <<~SYS
        Você é o assistente sênior de agendamento e produtividade do sistema Azaleia.
        Sua função é distribuir tarefas em aberto (sem data ou atrasadas) na agenda do usuário, calculando o melhor dia e horário de conclusão (schedule_at) para cada uma.
        Siga rigorosamente:
        1. Respeite a jornada de trabalho, dias de trabalho e intervalo de almoço do usuário.
        2. Respeite as preferências de rotina e atividades descritas pelo usuário.
        3. Evite sobrecarregar horários e dias que já possuem tarefas agendadas.
        4. Aloque tarefas mais longas e estratégicas/urgentes nos melhores horários segundo o perfil do usuário.
        5. Retorne APENAS um objeto JSON no formato exato:
        {
          "summary": "Resumo em 2 a 3 frases explicando a estratégia adotada para organizar a agenda",
          "suggestions": [
            {
              "task_id": 123,
              "suggested_schedule_at": "YYYY-MM-DDTHH:MM",
              "reasoning": "Justificativa clara em 1 frase do porquê este dia e horário foram escolhidos"
            }
          ]
        }
      SYS

      prompt = <<~PROMPT
        DATA E HORA ATUAL: #{current_time_info}

        JORNADA E ROTINA DO USUÁRIO:
        - #{user.work_schedule_summary}

        PERFIL PSICOMÉTRICO:
        - EQ-i: #{eqi_summary}
        - MBTI: #{mbti_summary}

        TAREFAS JÁ AGENDADAS PARA OS PRÓXIMOS DIAS (Evitar conflito de horário):
        #{scheduled_payload}

        TAREFAS EM ABERTO PARA AGENDAR:
        #{tasks_payload}

        Gere a sugestão de agendamento com data e hora para cada uma das tarefas em aberto listadas.
      PROMPT

      res = GeminiClient.generate_content(prompt, system_instruction: system_instruction, json_response: true, user: user, action_name: "Agendamento de Tarefas em Aberto")

      unless res.is_a?(Hash) && res["suggestions"].is_a?(Array)
        res = {
          "summary" => "Análise concluída com sugestões de reagendamento.",
          "suggestions" => []
        }
      end

      res
    end

    def self.apply_schedules(user, schedule_params)
      return 0 if schedule_params.blank?

      updated_count = 0
      ActiveRecord::Base.transaction do
        schedule_params.each do |task_id, attrs|
          next if attrs["selected"] == "0" || attrs["selected"] == false

          task = user.tasks.find_by(id: task_id)
          next unless task

          if attrs["schedule_at"].present?
            new_schedule = Time.zone.parse(attrs["schedule_at"]) rescue nil
            if new_schedule
              task.update!(schedule_at: new_schedule)
              updated_count += 1
            end
          end
        end
      end

      updated_count
    end
  end
end
