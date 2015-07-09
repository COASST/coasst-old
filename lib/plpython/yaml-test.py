import yaml

def construct_ruby_object(loader, suffix, node):
    return loader.construct_yaml_map(node)

def construct_ruby_sym(loader, node):
    return loader.construct_yaml_str(node)

yaml.add_multi_constructor(u"!ruby/object:", construct_ruby_object)
yaml.add_constructor(u"!ruby/sym", construct_ruby_sym)

def yaml_test(record, key):
    if record is None or key is None:
        return None

    record_yaml = yaml.load(record)
    attributes = record_yaml['attributes']
    if not attributes.has_key(key):
        return None
    else:
        return attributes[key]

f = open('yaml-test.yaml', 'r').read()

print yaml_test(f, 'photo_count')
