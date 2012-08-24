vm "test_vm" do  
  base_image "ubuntu"
  run_list ["recipe[base]"]
end
