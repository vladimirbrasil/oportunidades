class ScrapeCorenOportunidades
  require 'mechanize'
  
  attr_reader :oportunidades

  def initialize(args={})
    @url = args[:url]
    @oportunidades = get_oportunidades
    save_to_file
    @oportunidades
  end

  def get_oportunidades
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    page = a.get(@url)
    oportunidades = []
    page.links.each do |link|
      if /.*nferm.* - .*/.match(link.to_s)
        oport = link.click
        texto = CGI::escapeHTML(oport.body)
        unless /.*[Ee]nfermeir[oa]*/.match(texto)
          salario = /\d{1,3}\.\d{1,3},\d{1,2}/.match(texto)
          horario = /\d{1,2}h.*?\d{1,2}h\d{0,2}/.match(texto)
          horario = '' if /.*17h15.*/.match(horario.to_s)
          email = /\S{1,100}@[A-Za-z\.]{1,100}/.match(texto)
          url = "http://www.portalcoren-rs.gov.br/#{link.uri}"
          oportunidades << [salario, horario, email, url].join("\t") 
        end
      end
    end
    oportunidades
  end
  
  def save_to_file
    File.open('oportunidades.txt', 'w') do |f|
      f.write(@oportunidades.join("\n"))
    end
    # Colar conteúdo do arquivo no Google sheets. Ordenar por salários, decrescentes.
  end

end

oportunidades_coren = ScrapeCorenOportunidades.new(
  url: "http://www.portalcoren-rs.gov.br/index.php?categoria=servicos&pagina=oportunidades"
)

