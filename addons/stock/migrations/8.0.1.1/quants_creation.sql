-- Main Function
DROP FUNCTION IF EXISTS action_done();
CREATE OR REPLACE FUNCTION action_done()
RETURNS integer[] AS $$
    DECLARE
        move_qty integer;
        error_qty integer;
        quants_used integer[];
        quants_to_use float[];
        from_uom product_uom%rowtype;
        to_uom product_uom%rowtype;
        move stock_move%rowtype;
        template integer;
        current_qty float;
    BEGIN
        move_qty := 0;
        error_qty := 0;
        FOR move IN
                SELECT *
                FROM stock_move
                WHERE state='done'
                AND product_uom_qty > 0
                AND product_id >= {begin_product_id}
                AND product_id < {end_product_id}
                AND company_id = 25
                ORDER BY date ASC LOOP
            BEGIN
                move_qty := move_qty + 1;
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
        RETURN array[[move_qty, error_qty]];
    END;
    $$ LANGUAGE plpgsql;

SELECT action_done();
