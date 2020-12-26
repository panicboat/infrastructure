class Option
  require 'optparse'

  def initialize
    @options = {}
    OptionParser.new do |o|
      o.on('-t', '--template ITEM', 'template file path') { |v| @options[:template] = v }
      o.on('-p', '--parameter ITEM', 'parameter file path') { |v| @options[:parameter] = v }
      o.on('-h', '--help', 'show this help') {|v| puts o; exit }
      o.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def get(name)
    @options[name]
  end

  def get_extras
    ARGV
  end
end

class Template
  require 'erb'
  require 'yaml'
  require 'awesome_print'
  require 'active_support/all'

  def initialize(template_file, param_file)
    @template_file = template_file
    @param_file = param_file
  end

  def erb

    def _eval_erb(_erb, p = {})
      p = p.with_indifferent_access
      _erb.result(binding)
    end

    template_string = File.open(@template_file).read
    erb = ERB.new(template_string, nil, '-%')
    erb.filename = @template_file
    output = _eval_erb(erb, YAML.load_file(@param_file))
  end
end

option = Option.new
template = Template.new(option.get(:template), option.get(:parameter))
puts template.erb
