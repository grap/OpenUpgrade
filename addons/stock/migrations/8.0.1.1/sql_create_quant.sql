-- Main Function
DROP FUNCTION IF EXISTS action_done();
CREATE OR REPLACE FUNCTION action_done()
RETURNS integer AS $$
    DECLARE
        error_qty integer;
        quants_used integer[];
        quants_to_use float[];
        from_uom product_uom%rowtype;
        to_uom product_uom%rowtype;
        move stock_move%rowtype;
        template integer;
        current_qty float;
    BEGIN
        error_qty := 0;
        FOR move IN
                SELECT *
                FROM stock_move
                WHERE state='done'
                AND product_uom_qty > 0
                AND id >= {first_move_id}
                AND id <= {last_move_id}
                ORDER BY date ASC LOOP
            BEGIN
                template := (SELECT product_tmpl_id FROM product_product WHERE id=move.product_id);
                SELECT * INTO from_uom FROM product_uom WHERE id=move.product_uom;
                SELECT * INTO to_uom FROM product_uom WHERE id IN (SELECT uom_id FROM product_template WHERE id = template);
                SELECT compute_qty_obj(from_uom, move.product_uom_qty, to_uom, 'HALF-UP') INTO current_qty;
                SELECT quants_get(move, current_qty, ' AND qty > 0', move.location_id) INTO quants_to_use;
                SELECT quants_move(move, quants_to_use) INTO quants_used;

            EXCEPTION WHEN others THEN
                error_qty := error_qty +1;
                INSERT INTO stock_quants_openupgrade_8_log(stock_move_id, sql_code, sql_message)
                    VALUES (move.id, SQLSTATE, SQLERRM);

            END;
        END LOOP;
        RETURN error_qty;
    END;
    $$ LANGUAGE plpgsql;

SELECT action_done();
