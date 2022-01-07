CREATE OR REPLACE FUNCTION jsonb_update(base jsonb, replacement jsonb) 
RETURNS jsonb AS
$$
BEGIN
  RETURN jsonb_filter(jsonb_merge(base, replacement));
END;
$$ LANGUAGE plpgsql;
