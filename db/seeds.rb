  [
    { name: "Deve ser feito", value: 2.0 },
    { name: "É bom fazer", value: 1.5 },
    { name: "Opcional", value: 1.0 }
  ].each do |multiplier_data|
    Multiplier.find_or_create_by!(name: multiplier_data[:name]) do |m|
      m.value = multiplier_data[:value]
    end
  end
