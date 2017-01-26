-- Create a Log table that will be populated if the
-- treatment of a move fail.
CREATE TABLE stock_quants_openupgrade_8_log(
    stock_move_id integer NOT NULL,
    sql_code character varying NOT NULL,
    sql_message text
);
