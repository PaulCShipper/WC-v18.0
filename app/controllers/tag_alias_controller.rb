class TagAliasController < ApplicationController
  before_filter :admin_only, :only => [:create, :update]
  verify :method => :post, :only => [:create, :update]

  def create
    ta = TagAlias.new(params[:tag_alias].merge(:is_pending => true))
    
    if ta.save
      flash[:notice] = "Tag alias created"
    else
      flash[:notice] = "Error: " + ta.errors.full_messages.join(", ")
    end
    
    redirect_to :action => "index"
  end

  def index
    set_title "Tag Aliases"
    
    if params[:commit] == "Search Implications"
      redirect_to :controller => "tag_implication", :action => "index", :query => params[:query]
      return
    end
    
    if params[:query]
      name = "%" + params[:query].to_escaped_for_sql_like + "%"
      @aliases = TagAlias.paginate :order => "is_pending DESC, name", :per_page => 20, :conditions => ["name LIKE ? ESCAPE E'\\\\' OR alias_id IN (SELECT id FROM tags WHERE name ILIKE ? ESCAPE E'\\\\')", name, name], :page => params[:page]
    else
      @aliases = TagAlias.paginate :order => "is_pending DESC, name", :per_page => 20, :page => params[:page]
    end

    respond_to_list("aliases")
  end

  def update
    ids = params[:aliases].keys

    case params[:commit]
    when "Fix"
      ids.each do |tag_alias_id|
        tag_alias = TagAlias.find(tag_alias_id)
        TagAlias.fix(tag_alias.name)
      end
      
      flash[:notice] = "Tag aliases fixed"
      redirect_to :action => "index"
      
    when "Delete"
      ids.each {|x| TagAlias.find(x).destroy_and_notify(@current_user, params[:reason])}
    
      flash[:notice] = "Tag aliases deleted"
      redirect_to :action => "index"

    when "Approve"
      ids.each do |x|
      	if CONFIG["enable_asynchronous_tasks"]
      	  JobTask.create(:task_type => "approve_tag_alias", :status => "pending", :data => {"id" => x, "updater_id" => @current_user.id, "updater_ip_addr" => request.remote_ip})
      	else
      	  TagAlias.find(x).approve(@current_user.id, request.remote_ip)
      	end
      end
      
      flash[:notice] = "Tag alias approval jobs created"
      redirect_to :controller => "job_task", :action => "index"
    end
  end
  
  def expire
    TagAlias.find(params[:id]).expire_cache
    render :nothing => true
  end
end
