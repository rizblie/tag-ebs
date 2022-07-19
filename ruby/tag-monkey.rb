require 'aws-sdk'
required_tag = 'Team'
ec2_resource = Aws::EC2::Resource.new
untagged_volumes = []
ec2_resource.volumes.each do |volume|
    unless volume.tags.any? { |tag| tag.key.eql?(required_tag) }
        untagged_volumes << { id: volume.volume_id, instance_id: volume.attachments.first.instance_id }
    end
end

untagged_volumes.each do |volume|
    if ec2_resource.instance(volume[:instance_id]).tags.any? { |tag| tag.key.eql?(required_tag)}
        instance_tag = (ec2_resource.instance(volume[:instance_id]).tags.select {
            |tag| tag.key.eql?(required_tag)
        }).first.value
        ec2_resource.volume(volume[:id]).create_tags({tags: [{key: required_tag, value: instance_tag, },]})
        puts "Tagged #{volume[:instance_id]} with #{required_tag} = #{instance_tag}"
    else
        puts "Tag:#{required_tag} was not present on instance for volume: #{volume[:instance_id]}"
    end
end