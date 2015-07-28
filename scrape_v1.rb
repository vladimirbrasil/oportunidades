class ScrapeCorenOportunidades
  require 'mechanize'
  
  attr_reader :oportunidades, :apenas_links_com_oportunidades

  def initialize(args={})
    @url = args[:url]
    @links_page = get_links_page
    @apenas_links_com_oportunidades = get_links_de_oportunidades(@links_page)

    @oportunidades = []
    @apenas_links_com_oportunidades.each do |link|
      infos_relevantes_oportunidade = extract_pages_core_informations(link)
      @oportunidades << infos_relevantes_oportunidade if infos_relevantes_oportunidade
    end

    save_to_file

    # @oportunidades = get_oportunidades
    # save_to_file
    # @oportunidades
  end

  def get_links_page
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    page = a.get(@url)
  end

  def get_links_de_oportunidades(links_page)
    links = links_page.links
    links.select { |link| /.*nferm.* - .*/.match(link.to_s) }
    # links.compact # remove nil values
  end

  def extract_pages_core_informations(link_contendo_oportunidade)
    oportunity_page = link_contendo_oportunidade.click
    texto = CGI::escapeHTML(oportunity_page.body)
    if /.*[Ee]nfermeir[oa]*/.match(texto)
      nil #Vagas de enfermeiro não interessam. Apenas de Técnico de Enfermagem.
    else
      salario = /\d{1,3}\.\d{1,3},\d{1,2}/.match(texto)
      horario = /\d{1,2}h.*?\d{1,2}h\d{0,2}/.match(texto)
      horario = '' if /.*17h15.*/.match(horario.to_s)
      email = /\S{1,100}@[A-Za-z\.]{1,100}/.match(texto)
      url = "http://www.portalcoren-rs.gov.br/#{link_contendo_oportunidade.uri}"
      oportunidade = [salario, horario, email, url].join("\t") 
    end
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

