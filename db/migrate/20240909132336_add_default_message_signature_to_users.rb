class AddDefaultMessageSignatureToUsers < ActiveRecord::Migration[7.0]
  def up
    create_trigger('set_default_message_signature_before_insert', generated: true, compatibility: 1)
      .on('users')
      .before(:insert)
      .for_each(:row) do
      <<-SQL.squish
        BEGIN
          IF NEW.message_signature IS NULL THEN
            NEW.message_signature := NEW.name;
          END IF;
          RETURN NEW;
        END;
      SQL
    end
  end

  def down
    drop_trigger('set_default_message_signature_before_insert', 'users', generated: true)
  end
end
