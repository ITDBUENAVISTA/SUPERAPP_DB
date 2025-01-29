CREATE OR REPLACE FUNCTION trigger_generar_plan_amortizacion()
RETURNS TRIGGER AS $$
BEGIN
    -- Llamar a la función generar_plan_amortizacion después de insertar o actualizar un cliente
    PERFORM generar_plan_amortizacion(
        NEW.CLI_ID,                  -- ID del cliente
        NEW.CLI_SALDO_CAPITAL,       -- Saldo de capital del cliente
        NEW.CLI_VALOR_CUOTA,         -- Valor de la cuota
        NEW.CLI_NUMERO_CUOTAS        -- Número de cuotas
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
