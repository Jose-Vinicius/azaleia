module Ai
  class GoalDecomposerService
    def self.call(user, goal, create_tasks: false)
      system_instruction = <<~SYS
        Você é um especialista em gerenciamento de projetos e decomposição de tarefas no sistema Azaleia.
        Sua missão é pegar uma Meta SMART e quebrá-la em 3 a 6 tarefas acionáveis, concretas e estimadas em minutos.
        Retorne APENAS um objeto JSON com a chave "tasks" contendo um array de objetos com:
        - title: String (título claro e imperativo da tarefa)
        - description: String (passos de execução)
        - estimated_minutes: Integer (duração estimada em minutos, ex: 30, 45, 60, 90)
        - multiplier_name: String (um dos seguintes valores exatos: "Rotina", "Prioridade", "Urgente", "Estratégico")
      SYS

      prompt = <<~PROMPT
        META SMART PARA DECOMPOR:
        - Título: #{goal.title}
        - Descrição: #{goal.description}
        - Específico: #{goal.smart_specific}
        - Mensurável: #{goal.smart_measurable}
        - Prazo Temporal: #{goal.smart_timebound}
        - Foco Psicométrico: #{goal.psychometric_focus}

        Gere um plano de tarefas acionáveis para atingir esta meta.
      PROMPT

      res = GeminiClient.generate_content(prompt, system_instruction: system_instruction, json_response: true)
      tasks_data = res.is_a?(Hash) && res["tasks"].is_a?(Array) ? res["tasks"] : []

      if create_tasks
        created_records = []
        multipliers_map = Multiplier.all.index_by { |m| m.name.downcase }

        tasks_data.each do |t_data|
          mult_name = t_data["multiplier_name"].to_s.downcase
          multiplier = multipliers_map[mult_name] || multipliers_map.values.first

          task = user.tasks.create!(
            title: t_data["title"],
            description: t_data["description"],
            estimated_minutes: (t_data["estimated_minutes"] || 30).to_i,
            goal: goal,
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
