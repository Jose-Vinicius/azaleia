module Ai
  class OkrDecomposerService
    def self.call(user, target, create_tasks: false)
      okr = target.is_a?(Okr) ? target : target.okr
      key_result = target.is_a?(KeyResult) ? target : nil

      system_instruction = <<~SYS
        Você é um especialista em OKRs (Objectives and Key Results) e decomposição estratégica no sistema Azaleia.
        Sua missão é analisar o Objetivo do OKR e/ou o Resultado-Chave (KR) e quebrá-lo em 3 a 6 tarefas operacionais acionáveis, concretas e estimadas em minutos.
        Retorne APENAS um objeto JSON com a chave "tasks" contendo um array de objetos com:
        - title: String (título claro e imperativo da tarefa)
        - description: String (passos de execução detalhados)
        - estimated_minutes: Integer (duração estimada em minutos, ex: 30, 45, 60, 90)
        - multiplier_name: String (um dos seguintes valores exatos: "Rotina", "Prioridade", "Urgente", "Estratégico")
      SYS

      target_info = if key_result
        <<~INFO
          OBJETIVO OKR: #{okr.title} (#{okr.quarter})
          RESULTADO-CHAVE (KR) PARA DECOMPOR: #{key_result.title}
        INFO
      else
        <<~INFO
          OBJETIVO OKR PARA DECOMPOR:
          - Título: #{okr.title}
          - Trimestre: #{okr.quarter}
          - Descrição: #{okr.description}
          - KRs atuais: #{okr.key_results.map(&:title).join("; ")}
        INFO
      end

      prompt = <<~PROMPT
        #{target_info}

        Gere um plano de tarefas acionáveis e concretas para avançar este Resultado-Chave/OKR.
      PROMPT

      res = GeminiClient.generate_content(prompt, system_instruction: system_instruction, json_response: true)
      tasks_data = res.is_a?(Hash) && res["tasks"].is_a?(Array) ? res["tasks"] : []

      if create_tasks
        created_records = []
        multipliers_map = Multiplier.all.index_by { |m| m.name.downcase }

        target_kr = key_result || okr.key_results.first
        unless target_kr
          target_kr = okr.key_results.create!(title: "Resultados da IA para #{okr.title}")
        end

        tasks_data.each do |t_data|
          mult_name = t_data["multiplier_name"].to_s.downcase
          multiplier = multipliers_map[mult_name] || multipliers_map.values.first

          task = user.tasks.create!(
            title: t_data["title"],
            description: t_data["description"],
            estimated_minutes: (t_data["estimated_minutes"] || 30).to_i,
            key_result: target_kr,
            multiplier: multiplier,
            status: "pending"
          )
          created_records << task
        end
        created_records
      else
        tasks_data
      end
    end
  end
end
