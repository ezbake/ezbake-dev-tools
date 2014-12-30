module VisibilityHelper
    # ex: TOP SECRET//REL TO USA:A|B|(C&D):r(8,15,23)d(1,5,9):823421123:true
    def self.from_string str
        formalVis, external_vis, platform_vis, purge_id, composite = str.split ':'
        raise StandardError, "Could not read the supplied visibility string: #{str.inspect}! Format your visibility as
 'formal-visibility[:external-vis][:platform-vis][:purge_id][:composite] where platform-vis can be like:
 'r(1,2,3)w(1,2,3)d(1,2,3)m(1,2,3)'!" if formalVis.nil?
 
        vis = Visibility.new.setFormalVisibility(formalVis)
        markings = AdvancedMarkings.new
        if external_vis || platform_vis || purge_id || composite
            markings.setExternalCommunityVisibility(external_vis) unless external_vis.empty?
            markings.setPlatformObjectVisibility(platform_vis_from_string(platform_vis)) unless platform_vis.empty?
            markings.setId(purge_id.to_i) unless purge_id.empty?
            unless composite.empty?
                composite.downcase!
                markings.setComposite(composite == 't' || composite == 'true')
            end
        end
        
        vis.setAdvancedMarkings(markings)
    end
    
    def self.platform_vis_from_string platform_vis
        components = platform_vis.split ')'
        vis = PlatformObjectVisibilities.new
        components.each do |c|
            content = Java::java.util.HashSet.new()
            c[2..-1].split(',').map(&:to_i).each {|x| content.add x }
            
            case c[0]
            when 'r' then vis.setPlatformObjectReadVisibility(content)
            when 'w' then vis.setPlatformObjectWriteVisibility(content)
            when 'd' then vis.setPlatformObjectDiscoverVisibility(content)
            when 'm' then vis.setPlatformObjectManageVisibility(content)
            end
        end
        vis
    end
    
    def self.to_binary vis
        Java::org.apache.thrift.TSerializer.new.serialize(vis)
    end
end