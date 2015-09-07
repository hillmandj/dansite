class BackfillProjectPositions < ActiveRecord::Migration
  def up
    projects_and_positions = {
      'Handy' => 0,
      'PublicStuff' => 1,
      'Chole + Isabel' => 2,
      'Tic Tac Toe' => 3,
      'Huffman Encoder' => 4,
      'Sort Bot' => 5
    }

    projects_and_positions.each do |name, pos|
      project = Project.find_by_name(name)
      project.update(position: pos) if project
    end
  end

  def down
    Project.update_all(:position => nil)
  end
end
