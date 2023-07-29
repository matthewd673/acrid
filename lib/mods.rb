require_relative "acrid"

def load_mod_code(mod_code)
  eval(mod_code)
  loaded = mod # function returning mod class

  # ensure mod class follows expected conventions (or close enough)
  if loaded.name == nil || loaded.version == nil
    return nil
  else
    return loaded
  end
end

def load_all_mods()
  Dir["./config/mods/*.rb"].each { |p|
    begin
      file = File.open(p, "r")
      mod_code = file.read
      loaded = load_mod_code(mod_code)

      # load mod into acrid if valid
      if loaded != nil
        Acrid.register_mod(loaded)
      end
    rescue
      # TODO: ??
    end
  }
end