class CreateAppraisalMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_messages do |t|
      t.integer :user_id
      t.integer :appraisal_id
      t.text :content

      t.timestamps
    end
  end
end
