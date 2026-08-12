module Ai
  class GoalSuggestionService
    def self.suggest_goals(user)
      low_subscales = user.low_eqi_subscales.map { |s| s.sub("_score", "") }
      mbti = user.mbti_profile&.final_type || "N/A"
      eqi_total = user.eqi_profile&.total_eq || "N/A"

      system_instruction = <<~SYS
        Você é um especialista em psicologia organizacional e metodologia SMART de metas.
        Sua tarefa é sugerir exatamente 3 Metas SMART altamente personalizadas para o usuário com base nos seus dados psicométricos e de produtividade.
        Retorne APENAS um objeto JSON com uma chave "goals" contendo um array de 3 objetos com os seguintes atributos:
        - title: String (título curto da meta)
        - description: String (resumo do propósito)
        - smart_specific: String (detalhes específicos do que realizar)
        - smart_measurable: String (como medir o progresso)
        - smart_achievable: String (por que é atingível)
        - smart_relevant: String (relevância para o perfil do usuário)
        - smart_timebound: String (cronograma/prazo)
        - psychometric_focus: String (nome da subescala ou competência em foco, ex: "reality_testing", "assertiveness")
        - target_days: Integer (dias a partir de hoje para conclusão, ex: 30, 60, 90)
      SYS

      prompt = <<~PROMPT
        DADOS DO USUÁRIO:
        - Perfil MBTI: #{mbti}
        - EQ-i Total: #{eqi_total}
        - Subescalas do EQ-i com menor pontuação (<85): #{low_subscales.join(', ').presence || 'Nenhuma subescala crítica identificada'}
        - Metas Ativas Atuais: #{user.goals.active.pluck(:title).join('; ')}

        Gere 3 sugestões de Metas SMART que fortaleçam as competências comportamentais e impulsionem a produtividade do usuário.
      PROMPT

      res = GeminiClient.generate_content(prompt, system_instruction: system_instruction, json_response: true)
      goals_data = res.is_a?(Hash) && res["goals"].is_a?(Array) ? res["goals"] : []
      
      goals_data.map do |g|
        days = (g["target_days"] || 30).to_i
        g["target_date"] = (Date.today + days.days).to_s
        g
      end
    end

    def self.generate_smart_fields(user, title:, description: nil)
      low_subscales = user.low_eqi_subscales.map { |s| s.sub("_score", "") }
      mbti = user.mbti_profile&.final_type || "N/A"

      system_instruction = <<~SYS
        Você é um assistente de IA especialista em metodologia de metas SMART.
        Dado o título e a descrição de uma meta informada pelo usuário, você deve desdobrar e estruturar os 5 componentes SMART e o foco psicométrico.
        Retorne APENAS um objeto JSON com as chaves:
        - smart_specific: String
        - smart_measurable: String
        - smart_achievable: String
        - smart_relevant: String
        - smart_timebound: String
        - psychometric_focus: String
        - target_days: Integer (dias sugeridos para conclusão, ex: 30)
      SYS

      prompt = <<~PROMPT
        TÍTULO DA META: #{title}
        DESCRIÇÃO ADICIONAL: #{description.presence || 'Não informada'}
        PERFIL MBTI DO USUÁRIO: #{mbti}
        FOCOS PSICOMÉTRICOS RECOMENDADOS (EQ-i < 85): #{low_subscales.join(', ').presence || 'Equilibrado'}

        Desdobre esta meta na estrutura SMART completa.
      PROMPT

      res = GeminiClient.generate_content(prompt, system_instruction: system_instruction, json_response: true)
      if res.is_a?(Hash)
        days = (res["target_days"] || 30).to_i
        res["target_date"] = (Date.today + days.days).to_s
      end
      res
    end
  end
end
