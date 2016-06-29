require "spec_helper"

describe "Migrations" do
  around do |example|
    sql_definition = <<~EOS
      CREATE OR REPLACE FUNCTION test() RETURNS text AS $$
      BEGIN
          RETURN 'test';
      END;
      $$ LANGUAGE plpgsql;
    EOS
    with_definition(name: :test, sql_definition: sql_definition) do
      example.run
    end
  end

  it "can run migrations that create functions" do
    migration = Class.new(ActiveRecord::Migration) do
      def up
        create_function :test
      end
    end

    expect { run_migration(migration, :up) }.not_to raise_error
  end

  it "can run migrations that drop functions" do
    connection.create_function(:test)

    migration = Class.new(ActiveRecord::Migration) do
      def up
        drop_function :test
      end
    end

    expect { run_migration(migration, :up) }.not_to raise_error
  end
end