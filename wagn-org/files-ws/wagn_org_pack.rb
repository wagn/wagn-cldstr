class Wagn::Renderer::Html

  define_view :shade do |args|
    wrap :shade, args do
      %{
        <h1>
          <a class="shade-link">#{ fancy_title card }</a>
        </h1>
        <div class="shade-content">#{ render_core }</div>
      }
    end
  end


end
