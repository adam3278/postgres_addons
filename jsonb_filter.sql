CREATE OR REPLACE FUNCTION jsonb_filter(messy jsonb) 
RETURNS jsonb AS
$$
DECLARE
  m jsonb DEFAULT '{}'::jsonb;
  m_row record;
  i smallint DEFAULT 0;
BEGIN
IF jsonb_typeof(messy) = 'object' THEN
  FOR m_row IN (SELECT ob.* FROM jsonb_each(messy) ob
  	WHERE NOT (jsonb_typeof(ob.value) = 'string' and ob.value::text = '""')
    and NOT (jsonb_typeof(ob.value) = 'array' and jsonb_array_length(ob.value) = 0)
    and NOT (jsonb_typeof(ob.value) = 'object' and (SELECT count(*) FROM jsonb_object_keys(ob.value)) = 0)
    and jsonb_typeof(ob.value) != 'null')
  LOOP
    m = jsonb_set(m, ('{' || m_row.key || '}')::text[], jsonb_filter(m_row.value));
  END LOOP;
  RETURN m;
ELSIF jsonb_typeof(messy) = 'array' THEN
  m = '[]'::jsonb;
  FOR m_row IN (SELECT jsonb_array_elements(messy) as value)
  LOOP
    IF NOT (jsonb_typeof(m_row.value) = 'string' and m_row.value::text = '""')
    and NOT (jsonb_typeof(m_row.value) = 'array' and jsonb_array_length(m_row.value) = 0)
    and NOT (jsonb_typeof(m_row.value) = 'object' and (SELECT count(*) FROM  jsonb_object_keys(m_row.value)) = 0)
    and jsonb_typeof(m_row.value) != 'null'
    THEN
      m = jsonb_set(m, ('{' || i || '}')::text[], jsonb_filter(m_row.value));
      i = i + 1;
    END IF;
  END LOOP;
  RETURN m;
ELSE
  m = messy;
  IF m::text != '""' THEN
  	RETURN m;
  ELSE
  	RETURN NULL;
  END IF;
END IF;
END;
$$ LANGUAGE plpgsql;
