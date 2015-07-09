CREATE PROCEDURAL LANGUAGE 'plpythonu';

CREATE OR REPLACE FUNCTION original_value(record text, key text)
  RETURNS text AS
$$
    import yaml
    def construct_ruby_object(loader, suffix, node):
        return loader.construct_yaml_map(node)

    def construct_ruby_sym(loader, node):
        return loader.construct_yaml_str(node)

    yaml.add_multi_constructor(u"!ruby/object:", construct_ruby_object)
    yaml.add_constructor(u"!ruby/sym", construct_ruby_sym)
    yaml.add_constructor(u"!induktiv.at,2007/BigDecimal", construct_ruby_sym)

    record_yaml = yaml.load(record)
    attributes = record_yaml['attributes']
    if not attributes.has_key(key):
        return None
    else:
        return attributes[key]

$$ LANGUAGE plpythonu;
