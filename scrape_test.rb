require 'minitest/autorun'
load 'scrape.rb'

describe ScrapeCorenOportunidades do
  before do
    @scrape = ScrapeCorenOportunidades.new(
      url: "http://www.portalcoren-rs.gov.br/index.php?categoria=servicos&pagina=oportunidades",      
    )
    @links_page = @scrape.get_links_page
    @links_com_oportunidades = @scrape.get_links_de_oportunidades(@links_page)
  end

  describe "página de links" do
    it "deve conter vagas de técnico de enfermagem" do
      assert_match /.*[Tt].cnico de [Ee]nfermagem.*/, @links_page.body
    end

    it "apenas links contendo oportunidades devem ser selecionados" do
      assert_includes "Enfermagem", @links_com_oportunidades
    end

  end

end