# 📋 Proposta Técnica de Arquitetura e Integração: Ametista + Bismuto ➔ Azaleia (Atualizada)

Este documento especifica a proposta de alteração técnica para integrar os projetos **Ametista** (Motor EQ-i 2.0®) e **Bismuto** (Motor MBTI) ao **Azaleia** (Sistema de Produtividade & Gerenciamento de Tarefas em Ruby on Rails).

---

## 🎯 Resumo da Arquitetura
A integração utilizará **três novas entidades estruturadas no Banco de Dados do Azaleia**:
1. `Goal`: Tabela independente para Metas SMART.
2. `EqiProfile`: Tabela para dados parseados do teste de Inteligência Emocional (`ametista`).
3. `MbtiProfile`: Tabela para dados parseados de Tipologia de Personalidade (`bismuto`).

Toda a lógica diária de progresso, alertas de sobrecarga e alinhamento de tarefas é realizada com **consultas relacionais diretas em ActiveRecord (custo 0 de tokens)**. O uso de IA fica restrito ao gerador sob demanda de metas SMART.

---

## 1. 💎 Alterações no Projeto `Ametista` (EQ-i 2.0®)

### 📍 Objetivo
Exportar o relatório psicométrico do teste EQ-i 2.0® em formato JSON padronizado.

### 📄 Schema do JSON de Exportação (`ametista_export.json`)
```json
{
  "schema_version": "1.0",
  "source": "ametista",
  "assessment_id": "uuid-do-teste-eqi",
  "completed_at": "2026-08-11T10:00:00Z",
  "user": { "email": "usuario@exemplo.com", "name": "Nome do Usuário" },
  "scores": {
    "total_eq": 108,
    "validity": { "is_valid": true, "inconsistency_index": 3 },
    "wellbeing": { "status": "Balanced", "happiness_score": 112 },
    "subscales": {
      "self_regard": { "standard_score": 110, "threshold": "medium" },
      "self_actualization": { "standard_score": 115, "threshold": "high" },
      "emotional_self_awareness": { "standard_score": 95, "threshold": "medium" },
      "emotional_expression": { "standard_score": 82, "threshold": "low" },
      "assertiveness": { "standard_score": 88, "threshold": "medium" },
      "independence": { "standard_score": 105, "threshold": "medium" },
      "interpersonal_relationships": { "standard_score": 90, "threshold": "medium" },
      "empathy": { "standard_score": 102, "threshold": "medium" },
      "social_responsibility": { "standard_score": 100, "threshold": "medium" },
      "problem_solving": { "standard_score": 118, "threshold": "high" },
      "reality_testing": { "standard_score": 80, "threshold": "low" },
      "impulse_control": { "standard_score": 86, "threshold": "medium" },
      "flexibility": { "standard_score": 92, "threshold": "medium" },
      "stress_tolerance": { "standard_score": 104, "threshold": "medium" },
      "optimism": { "standard_score": 122, "threshold": "high" }
    }
  }
}
```

---

## 2. 🧪 Alterações no Projeto `Bismuto` (MBTI)

### 📍 Objetivo
Exportar o diagnóstico de perfil de personalidade e funções cognitivas em formato JSON.

### 📄 Schema do JSON de Exportação (`bismuto_export.json`)
```json
{
  "schema_version": "1.0",
  "source": "bismuto",
  "assessment_id": "uuid-do-teste-mbti",
  "completed_at": "2026-08-10T14:30:00Z",
  "user": { "email": "usuario@exemplo.com", "name": "Nome do Usuário" },
  "profile": {
    "final_type": "INTJ",
    "temperament_group": "Analistas",
    "temperament_code": "NT",
    "dichotomies": {
      "E_I": { "winner": "I", "pci_percentage": 78.5, "clarity": "Muito clara" },
      "S_N": { "winner": "N", "pci_percentage": 65.0, "clarity": "Clara" },
      "T_F": { "winner": "T", "pci_percentage": 82.0, "clarity": "Muito clara" },
      "J_P": { "winner": "J", "pci_percentage": 58.0, "clarity": "Moderada" }
    },
    "cognitive_hierarchy": {
      "dominant": { "code": "Ni", "name": "Intuição Introvertida" },
      "auxiliary": { "code": "Te", "name": "Pensamento Extrovertido" },
      "tertiary": { "code": "Fi", "name": "Sentimento Introvertido" },
      "inferior": { "code": "Ne", "name": "Intuição Extrovertida" }
    }
  }
}
```

---

## 3. 🌺 Alterações Estruturais no Projeto `Azaleia` (Ruby on Rails)

### 3.1. Novas Entidades do Banco de Dados

#### A. Tabela `goals` (Entidade Independente de Metas SMART)
```ruby
# db/migrate/20260811_create_goals.rb
class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      
      # Atributos SMART
      t.text :smart_specific
      t.text :smart_measurable
      t.text :smart_achievable
      t.text :smart_relevant
      t.text :smart_timebound
      
      t.integer :status, default: 1, null: false # 0: draft, 1: active, 2: paused, 3: completed
      t.date :target_date
      t.string :psychometric_focus # ex: "reality_testing", "assertiveness"
      
      t.timestamps
    end
  end
end
```

#### B. Tabela `eqi_profiles` (Armazenamento Estruturado do EQI)
```ruby
# db/migrate/20260811_create_eqi_profiles.rb
class CreateEqiProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :eqi_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :assessment_id
      t.integer :total_eq
      t.boolean :is_valid, default: true
      t.integer :happiness_score
      
      # 15 Subescalas Mapeadas Como Colunas Inteiras (Standard Scores 50-150)
      t.integer :self_regard_score
      t.integer :self_actualization_score
      t.integer :emotional_self_awareness_score
      t.integer :emotional_expression_score
      t.integer :assertiveness_score
      t.integer :independence_score
      t.integer :interpersonal_relationships_score
      t.integer :empathy_score
      t.integer :social_responsibility_score
      t.integer :problem_solving_score
      t.integer :reality_testing_score
      t.integer :impulse_control_score
      t.integer :flexibility_score
      t.integer :stress_tolerance_score
      t.integer :optimism_score
      
      t.datetime :imported_at
      t.timestamps
    end
  end
end
```

#### C. Tabela `mbti_profiles` (Armazenamento Estruturado do MBTI)
```ruby
# db/migrate/20260811_create_mbti_profiles.rb
class CreateMbtiProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :mbti_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :assessment_id
      t.string :final_type, null: false # ex: "INTJ"
      t.string :temperament_group       # ex: "Analistas"
      t.string :temperament_code        # ex: "NT"
      
      # Vencedor e Clareza das Dicotomias
      t.string :ei_winner
      t.decimal :ei_pci, precision: 5, scale: 2
      t.string :sn_winner
      t.decimal :sn_pci, precision: 5, scale: 2
      t.string :tf_winner
      t.decimal :tf_pci, precision: 5, scale: 2
      t.string :jp_winner
      t.decimal :jp_pci, precision: 5, scale: 2
      
      # Hierarquia das Funções Cognitivas
      t.string :dominant_function  # ex: "Ni"
      t.string :auxiliary_function # ex: "Te"
      t.string :tertiary_function  # ex: "Fi"
      t.string :inferior_function  # ex: "Ne"
      
      t.datetime :imported_at
      t.timestamps
    end
  end
end
```

#### D. Atualização na Tabela `tasks`
```ruby
# db/migrate/20260811_add_goal_to_tasks.rb
class AddGoalToTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :tasks, :goal, foreign_key: true, optional: true
  end
end
```

---

### 3.2. Serviços de Parsing & Importação (JSON ➔ DB)

Criar os serviços de parsing no Azaleia para receber o JSON uploadado e salvar direto nas tabelas `EqiProfile` e `MbtiProfile`:

```ruby
# app/services/psychometrics/eqi_importer_service.rb
module Psychometrics
  class EqiImporterService
    def self.call(user, json_data)
      data = JSON.parse(json_data)
      scores = data.dig("scores")
      subscales = scores.dig("subscales") || {}

      profile = user.eqi_profile || user.build_eqi_profile
      profile.assign_attributes(
        assessment_id: data["assessment_id"],
        total_eq: scores["total_eq"],
        is_valid: scores.dig("validity", "is_valid"),
        happiness_score: scores.dig("wellbeing", "happiness_score"),
        self_regard_score: subscales.dig("self_regard", "standard_score"),
        self_actualization_score: subscales.dig("self_actualization", "standard_score"),
        emotional_self_awareness_score: subscales.dig("emotional_self_awareness", "standard_score"),
        emotional_expression_score: subscales.dig("emotional_expression", "standard_score"),
        assertiveness_score: subscales.dig("assertiveness", "standard_score"),
        independence_score: subscales.dig("independence", "standard_score"),
        interpersonal_relationships_score: subscales.dig("interpersonal_relationships", "standard_score"),
        empathy_score: subscales.dig("empathy", "standard_score"),
        social_responsibility_score: subscales.dig("social_responsibility", "standard_score"),
        problem_solving_score: subscales.dig("problem_solving", "standard_score"),
        reality_testing_score: subscales.dig("reality_testing", "standard_score"),
        impulse_control_score: subscales.dig("impulse_control", "standard_score"),
        flexibility_score: subscales.dig("flexibility", "standard_score"),
        stress_tolerance_score: subscales.dig("stress_tolerance", "standard_score"),
        optimism_score: subscales.dig("optimism", "standard_score"),
        imported_at: Time.current
      )
      profile.save!
    end
  end
end
```

```ruby
# app/services/psychometrics/mbti_importer_service.rb
module Psychometrics
  class MbtiImporterService
    def self.call(user, json_data)
      data = JSON.parse(json_data)
      profile_data = data.dig("profile") || {}
      dichotomies = profile_data.dig("dichotomies") || {}
      hierarchy = profile_data.dig("cognitive_hierarchy") || {}

      profile = user.mbti_profile || user.build_mbti_profile
      profile.assign_attributes(
        assessment_id: data["assessment_id"],
        final_type: profile_data["final_type"],
        temperament_group: profile_data["temperament_group"],
        temperament_code: profile_data["temperament_code"],
        ei_winner: dichotomies.dig("E_I", "winner"),
        ei_pci: dichotomies.dig("E_I", "pci_percentage"),
        sn_winner: dichotomies.dig("S_N", "winner"),
        sn_pci: dichotomies.dig("S_N", "pci_percentage"),
        tf_winner: dichotomies.dig("T_F", "winner"),
        tf_pci: dichotomies.dig("T_F", "pci_percentage"),
        jp_winner: dichotomies.dig("J_P", "winner"),
        jp_pci: dichotomies.dig("J_P", "pci_percentage"),
        dominant_function: hierarchy.dig("dominant", "code"),
        auxiliary_function: hierarchy.dig("auxiliary", "code"),
        tertiary_function: hierarchy.dig("tertiary", "code"),
        inferior_function: hierarchy.dig("inferior", "code"),
        imported_at: Time.current
      )
      profile.save!
    end
  end
end
```

---

### 3.3. Relacionamentos no Model `User` do Azaleia

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :goals, dependent: :destroy
  has_one :eqi_profile, dependent: :destroy
  has_one :mbti_profile, dependent: :destroy
  
  # Métodos auxiliares para facilidade de uso
  def low_eqi_subscales
    return [] unless eqi_profile
    # Retorna subescalas com pontuação abaixo de 85
    eqi_profile.attributes.select { |k, v| k.end_with?("_score") && v.present? && v < 85 }.keys
  end
end
```

---

## 🚀 Benefícios da Estrutura Proposta

1. **Consultas SQL limpas e diretas:** Exemplo: `current_user.eqi_profile.reality_testing_score < 85` é validado instantaneamente em memória/SQL sem decodificar JSON.
2. **Histórico e Evolução:** Relações `has_one` (ou evoluíveis para `has_many` se quiser manter histórico de evolução dos testes ao longo dos anos).
3. **Desempenho de UI:** O formulário da tarefa em `views/tasks/_form.html.erb` busca apenas `current_user.goals.active` para montar o campo `<select>`.
