DROP FUNCTION IF EXISTS float_round(amount float, rounding float, rounding_method varchar);

DROP FUNCTION IF EXISTS compute_qty_obj(from_uom product_uom, qty float, to_unit product_uom, rounding_method varchar);

DROP FUNCTION IF EXISTS get_child_locations(source_location integer);

DROP FUNCTION IF EXISTS quants_get(move stock_move, quantity float, where_qty varchar, location integer);

DROP FUNCTION IF EXISTS create_quant(move stock_move, quantity float);

DROP FUNCTION IF EXISTS quant_split(quant integer, quantity float);

DROP FUNCTION IF EXISTS reconcile_negative(quant_rec integer, move stock_move);

DROP FUNCTION IF EXISTS quants_move(move stock_move, quants float[]);

DROP TABLE IF EXISTS stock_quants_openupgrade_8_log;
