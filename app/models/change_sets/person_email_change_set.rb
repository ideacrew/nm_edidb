module ChangeSets
  class PersonEmailChangeSet
    attr_reader :address_kind

    include ::ChangeSets::SimpleMaintenanceTransmitter

    def initialize(addy_kind)
      @address_kind = addy_kind
    end

    def perform_update(person, person_update, policies_to_notify, transmit = true)
      new_address = person_update.emails.detect { |au| au.email_type == address_kind }
      update_result = false
      if new_address.nil?
        person.remove_email_of(address_kind)
        update_result = person.save
      else
        person.set_email(Email.new(new_address.to_hash))
        update_result = person.save
      end
      return false unless update_result
      return true if (@address_kind == "work")
      if transmit
        notify_policies("change", "personnel_data", person_update.hbx_member_id, policies_to_notify, "urn:openhbx:terms:v1:enrollment#change_member_communication_numbers")
      end
      true
    end

    def applicable?(person, person_update)
      false
    end

    def applicable?(person, person_update)
      resource_address = person_update.emails.detect { |adr| adr.email_kind == @address_kind }
      record_address = person.emails.detect { |adr| adr.email_type == @address_kind }
      items_changed?(resource_address, record_address)
    end

    def items_changed?(resource_item, record_item)
      return false if (resource_item.nil? && record_item.nil?)
      return true if record_item.nil?
      !record_item.match(resource_item)
    end
  end
end
