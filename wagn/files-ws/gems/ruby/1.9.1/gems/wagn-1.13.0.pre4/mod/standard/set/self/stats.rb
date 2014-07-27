
format :html do
  view :core do |args|
    oldmem = session[:memory]
    session[:memory] = newmem = card.profile_memory
    stats = %{
      <table>
        <tr>
          <th>Stat</th>
          <th>Value</th>
          <th>Action</th>
        </tr>
        <tr>
          <td>cards</td>
          <td>#{ Card.where(:trash=>false).count }</td>
          <td></td>
        </tr>
        <tr>
          <td>trashed cards</td>
          <td>#{ Card.where(:trash=>true).count  }</td>
          <td>#{link_to 'delete all', wagn_path( 'update/:all?task=empty_trash' )}</td>
        </tr>
        <tr>
          <td>revisions</td>
          <td>#{ Card::Revision.count }</td>
          <td>#{link_to 'delete old', wagn_path( 'update/:all?task=delete_old_revisions' ) }</td>
        </tr>
          <tr><td>references</td>
          <td>#{ Card::Reference.count }</td>
          <td>#{link_to 'repair all', wagn_path( 'update/:all?task=repair_references' ) }</td>
        </tr>
        <tr>
          <td>sessions</td>
          <td>#{ ActiveRecord::SessionStore::Session.count }</td>
          <td>
            delete older than
            #{ delete_sessions_link 1 }
            #{ delete_sessions_link 2 }
            #{ delete_sessions_link 3 }
            months
          </td>
        </tr>
        <tr>
          <td>memory now</td>
          <td>#{ newmem }M</td>
          <td>#{link_to 'clear cache',  wagn_path( 'update/:all?task=clear_cache' ) }</td>
        </tr>
        #{
          if oldmem
            %{
              <tr>
                <td>memory prev</td>
                <td>#{ oldmem }M</td>
                <td></td>
              </tr>
              <tr>
                <td>memory diff</td>
                <td>#{ newmem - oldmem }M</td>
                <td></td>
              </tr>
              
            }
          end
        }
      </table>
    }
  end
  
  def delete_sessions_link months
    link_to months, wagn_path( "update/:all?task=delete_old_sessions&months=#{months}")
  end
end




def get_current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end

def profile_memory(&block)
  before = get_current_memory_usage
  file, line, _ = caller[0].split(':')
  if block_given?
    instance_eval(&block)
    (get_current_memory_usage - before) / 1024
  else
    before = 0
    (get_current_memory_usage - before) / 1024
  end.to_i
end
