import abc
from collections import OrderedDict
import glob
import os
from shutil import copyfile, rmtree

import argparse
import jinja2


EXTENSIONS = {'python': 'py', 'documentation': 'html'}

TYPE_NAMES = set([
    "boolean", "float", "long", "string", "int", "double", "array"])


class Constant(object):
    def __init__(
            self, variable_name, property_name, type_name, description,
            default_value=None):
        self.variable_name = variable_name
        self.property_name = property_name

        if type_name in TYPE_NAMES:
            self.type_name = type_name
        else:
            raise Exception(
                "Type '%s' not supported in %s" % (type_name, variable_name))

        self.default_value = default_value
        self.description = description

    def __str__(self):
        return '%s|%s|%s%s|%s' % (
            self.variable_name, self.property_name, self.type_name,
            "|" + self.default_value if self.default_value else '',
            self.description)


class HelperPlugin(object):
    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def generate(self, group, constants):
        return


def main():
    """
    Gets templates from templates/ folder and builds our allowed gen languages
    from that
    """
    gen_types = []
    for template in glob.glob("templates/*.template"):
        gen = os.path.splitext(os.path.basename(template))[0]
        gen_types.append(gen)

    gen_types += [
        f for f in os.listdir('templates')
        if os.path.isdir(os.path.join("templates", f))]

    parser = argparse.ArgumentParser(
        description=(
            "Generate constants in different languages from a constants file"))

    parser.add_argument(
        "constants_file", metavar="constants-file",
        help="Required: Location of constants template file")

    parser.add_argument(
        "gen", choices=gen_types,
        help="Required: The type of constants to generate")

    parser.add_argument(
        "-o", "--output-dir",
        help="The output location, defaults to gen-(gen).(gen)")

    parser.add_argument(
        "-H", "--helper", nargs="*", metavar="GROUP",
        help="Runs helper.main(group, constants[group])")

    parameters = parser.parse_args()

    constants = process_constants_file(parameters.constants_file)

    if parameters.output_dir:
        output = parameters.output_dir
    else:
        output = 'gen-%s.%s' % (
            parameters.gen, EXTENSIONS.get(parameters.gen, parameters.gen))

    if parameters.helper:
        try:
            import helper
        except (NameError, ImportError) as err:
            raise NameError("Error importing helper file: " + str(err))

        for group in parameters.helper:
            group_cons = constants.get(group)
            if group_cons is None:
                raise Exception(
                    "Constant group %s does not exist or has no constants" %
                    group)

            helper.Helper().generate(group, constants[group])

    process_template(constants, output, parameters.gen)


def process_constants_file(input_path):
    """
    Process constants from a file, and returns a dictionary of the constants
    """
    constants = OrderedDict()  # To keep order in constants file
    with open(input_path) as input_file:
        text = input_file.readlines()
        last_group = ''
        for line in text:
            line = line.split('#', 1)[0].strip()
            if not line:
                continue

            if line.startswith('[') and line.endswith(']'):
                last_group = line[1:-1]
                constants[last_group] = []
            else:
                split = line.split('|')
                if len(split) == 5:
                    cons = Constant(
                        split[0], split[1], split[2], split[4], split[3])

                    constants[last_group].append(cons)
                elif len(split) == 4:
                    cons = Constant(split[0], split[1], split[2], split[3])
                    constants[last_group].append(cons)
                else:
                    raise Exception("Not enough arguments: " + line)

    return OrderedDict(constants.items())  # Reverses dict


def process_template(constants, output, gen):
    gen_template = gen + '.template'
    gen_file = os.path.join('templates', gen_template)
    gen_dir = os.path.join('templates', gen)

    if os.path.isfile(gen_file):
        if os.path.exists(gen_dir):
            raise Exception(
                "Can't have %s and %s directory in templates/" %
                (gen_template, gen))

        jinja = jinja2.Environment(
            trim_blocks=True,
            loader=jinja2.PackageLoader(
                'ezconfiguration_constants_generator', 'templates'))

        if os.path.isdir(output):
            rmtree(output)

        with open(output, 'w') as out:
            template = jinja.get_template(gen_template)
            out.write(template.render(constants=constants))
    elif os.path.exists(gen_dir):
        output = os.path.splitext(output)[0]
        if os.path.exists(output):
            rmtree(output)

        process_template_directory(constants, output, gen_dir)
    else:
        raise Exception("error finding template")


def process_template_directory(constants, output, directory):
    template_files = [f for f in os.listdir(directory) if f[0] != '.']

    if not os.path.isdir(output):
        os.makedirs(output)

    for template_file in template_files:
        src = os.path.join(directory, template_file)
        dst = os.path.join(output, template_file)
        if os.path.isdir(src):
            process_template_directory(constants, dst, src)
        elif src.endswith(".template"):
            jinja = jinja2.Environment(
                trim_blocks=True,
                loader=jinja2.FileSystemLoader(os.path.dirname(src)))

            with open(dst.split(".template")[0], 'w') as out:
                template = jinja.get_template(os.path.basename(src))
                out.write(template.render(constants=constants))
        else:
            copyfile(src, dst)


if __name__ == "__main__":
    main()
