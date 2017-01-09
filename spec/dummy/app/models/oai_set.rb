class OaiSet < ::BlacklightOaiProvider::Set
  def description
    'This set begins with an H' if @spec.split(':').last.downcase.starts_with?('h')
  end
end
