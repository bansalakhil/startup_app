namespace :doc do
  namespace :diagram do
    task :models do
      sh "railroad -i -l -a -m -M | dot -Tpng > doc/models.png"
    end

    task :controllers do
      sh "railroad -i -l -C | neato -Tpng  > doc/controllers.png"
    end
  end

  task :diagrams => %w(diagram:models diagram:controllers)
end