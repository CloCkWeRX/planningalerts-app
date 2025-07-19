class RenameBoundaryToGeomInAuthorities < ActiveRecord::Migration[7.1]
  def change
    rename_column :authorities, :boundary, :geom
  end
end
