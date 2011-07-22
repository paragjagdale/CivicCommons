class Admin::PeopleController < Admin::DashboardController
  before_filter :prepare_stats, :only => [:index, :proxies]

  #GET admin/people/
  def index
    @people = Person.all
  end

  #GET admin/proxies
  def proxies
    @people = Person.proxy_accounts
    render :action => 'index'
  end

  #GET admin/people/new
  def new
    @person = Person.new(params[:person])
  end

  #POST admin/people
  def create
    @person = Person.new(params[:person])
    @person.create_proxy
    if @person.save
      flash[:notice] = "Thank you for creating the proxy account"
      redirect_to admin_people_path
    else
      render new_admin_person_path
    end
  end

  #GET admin/people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  #PUT admin/people/1
  def update
    @person = Person.find(params[:id])
    if params[:person] && params[:person][:admin] && current_person.admin?
      @person.admin = params[:person][:admin]
    end
    
    if @person.update_attributes(params[:person])
      flash[:notice] = "Successfully updated person record"
      redirect_to admin_people_path
    else
      render edit_admin_person_path(@person)
    end
  end

  def lock_access
    toggle_lock(:lock)
  end

  def unlock_access
    toggle_lock(:unlock)
  end

  #GET admin/people/1
  def show
    @person = Person.find(params[:id])
  end

  #DELETE admin/people/1
  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    respond_to do |format|
      format.html { redirect_to(admin_people_path) }
      format.json { redirect_to (admin_people_path)}
    end
  end

  def confirm
    @person = Person.find(params[:id])
    @person.confirm!
    redirect_to admin_people_path
  end

  protected

  def prepare_stats
    @stats = {
      :confirmed         => Person.confirmed_accounts.size,
      :unconfirmed       => Person.unconfirmed_accounts.size,
      :unconfirmed_real  => Person.unconfirmed_accounts.real_accounts.size,
      :unconfirmed_proxy => Person.proxy_accounts.size
    }
  end

  # Locks or unlocks a person's account which will disable login access
  # action = either :lock or :unlock
  def toggle_lock(action)
    @person = Person.find(params[:id])
    @person.send("#{action}_access!")
    flash[:notice] = "Successfully #{action}ed #{@person.name}"
    if params[:redirect_to]
      redirect_to :action => params[:redirect_to]
    else
      redirect_to admin_people_path
    end
  end

end
