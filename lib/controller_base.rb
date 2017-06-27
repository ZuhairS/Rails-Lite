require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @rendered = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @rendered
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Don't double render mate!" if already_built_response?
    @res.status = 302
    @res.location = url
    @rendered = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Don't double render mate!" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @rendered = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    #Not removing _controller from the controller name in path.
    template_content = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")

    content = ERB.new(template_content).result(binding)
    render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
