CREATE OR REPLACE FUNCTION generar_plan_amortizacion(
    p_cliente_id VARCHAR(100),
    p_saldo_capital NUMERIC,
    p_valor_cuota NUMERIC,
    p_numero_cuotas INTEGER
) RETURNS VOID AS $$
DECLARE
    v_numero_cuota INTEGER := 1; -- Contador de cuota
    v_tasa_interes NUMERIC := 0.19 / 12; -- Tasa de interés mensual
    v_pago_intereses NUMERIC;
    v_pago_capital NUMERIC;
BEGIN
    -- Eliminar registros existentes del cliente
    DELETE FROM TBL_PLAN_PAGOS;

    -- Bucle para generar el plan de amortización
    WHILE v_numero_cuota <= p_numero_cuotas LOOP
        -- Calcular el pago de intereses de la cuota actual
        v_pago_intereses := ROUND(p_saldo_capital * v_tasa_interes, 10); -- Cálculo exacto a 10 decimales

        -- Calcular el pago a capital de la cuota actual
        v_pago_capital := p_valor_cuota - v_pago_intereses;

        -- Si es la última cuota, ajusta el saldo restante a capital para evitar errores acumulativos
        IF v_numero_cuota = p_numero_cuotas THEN
            v_pago_capital := p_saldo_capital; -- Liquidar todo el saldo restante como capital
            v_pago_intereses := p_valor_cuota - v_pago_capital; -- Ajustar intereses
        END IF;

        -- Actualizar el saldo de capital restante
        p_saldo_capital := p_saldo_capital - v_pago_capital;

        -- Insertar los datos de la cuota en la tabla
        INSERT INTO TBL_PLAN_PAGOS (
            PLAN_ID,
            PLAN_NUMERO_CUOTA,
            PLAN_SALDO_CAPITAL,
            PLAN_PAGO_CAPITAL,
            PLAN_PAGO_INTERESES,
            PLAN_CUOTA_TOTAL,
            PLAN_CLIENTE_ID
        )
        VALUES (
            v_numero_cuota,
            v_numero_cuota,
            ROUND(p_saldo_capital, 2), -- Saldo redondeado
            ROUND(v_pago_capital, 2), -- Capital redondeado
            ROUND(v_pago_intereses, 2), -- Intereses redondeados
            ROUND(p_valor_cuota, 2), -- Cuota total redondeada
            p_cliente_id
        );

        -- Incrementar el número de cuota
        v_numero_cuota := v_numero_cuota + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
