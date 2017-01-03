module BlacklightOaiProvider
  class EmptyResumptionToken < ::OAI::Provider::ResumptionToken
    # Output an empty resumptionToken element
    def to_xml
      xml = Builder::XmlMarkup.new
      xml.resumptionToken('', hash_of_attributes)
      xml.target!
    end
  end
end
