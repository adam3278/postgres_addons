CREATE OR REPLACE FUNCTION jsonb_merge(base jsonb, replacement jsonb) 
RETURNS jsonb AS
$$
DECLARE
  u jsonb DEFAULT '{}'::jsonb;
  u_row record;
BEGIN
IF base IS NULL OR jsonb_typeof(base) != jsonb_typeof(replacement) THEN
  RETURN replacement;
ELSIF jsonb_typeof(base) = 'object' THEN
  u = base;
  FOR u_row IN (SELECT ob.* FROM jsonb_each(replacement) ob)
  LOOP
    u = jsonb_set(u, ('{' || u_row.key || '}')::text[], jsonb_merge((u->u_row.key)::jsonb, u_row.value));
  END LOOP;
  RETURN u;
ELSIF jsonb_typeof(base) = 'array' THEN
  RETURN base || replacement;
ELSE
  IF base::text != replacement::text THEN
  	RETURN replacement;
  ELSE
  	RETURN base;
  END IF;
END IF;
END;
$$ LANGUAGE plpgsql;
