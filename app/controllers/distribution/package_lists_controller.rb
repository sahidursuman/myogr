module Distribution
  class PackageListsController < ApplicationController
    # GET /package_lists
    # GET /package_lists.json
    def index
      @point = Point.find(params[:point_id])
      @package_lists = @point.package_lists.all
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: PackageListsDatatable.new(view_context) }
      end
    end

    # GET /package_lists/1
    # GET /package_lists/1.json
    def show
      @point = Point.find(params[:point_id])
      @package_list = if params[:id].present?
                        PackageList.find(params[:id])
                      elsif params[:date].present?
                        date = Date.parse params[:date]
                        package_list = @point.package_lists.where(date: date).first
                        if package_list.nil?
                          @point.package_lists.create(date: date, package_limit: @point.default_day_package_limit)
                        else
                          package_list
                        end
                      end
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @package_list }
        format.js
      end
    end

    # GET /package_lists/new
    # GET /package_lists/new.json
    def new
      @package_list = PackageList.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @package_list }
      end
    end

    # GET /package_lists/1/edit
    def edit
      @package_list = PackageList.find(params[:id])
    end

    # POST /package_lists
    # POST /package_lists.json
    def create
      @package_list = PackageList.new(params[:package_list])

      respond_to do |format|
        if @package_list.save
          format.html { redirect_to @package_list, notice: 'Package list was successfully created.' }
          format.json { render json: @package_list, status: :created, location: @package_list }
        else
          format.html { render action: "new" }
          format.json { render json: @package_list.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /package_lists/1
    # PUT /package_lists/1.json
    def update
      @package_list = PackageList.find(params[:id])

      respond_to do |format|
        if @package_list.update_attributes(params[:package_list])
          format.html { redirect_to @package_list, notice: 'Package list was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @package_list.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /package_lists/1
    # DELETE /package_lists/1.json
    def destroy
      @package_list = PackageList.find(params[:id])
      @package_list.destroy

      respond_to do |format|
        format.html { redirect_to package_lists_url }
        format.json { head :no_content }
      end
    end

    #TODO Исправить на запрос.
    def find_package
      point = Point.find(params[:point_id])
      @available_packages = [];
      point.package_lists.each do |list|
        formatted_date = list.date.strftime('%d.%m.%Y')
        if formatted_date.scan(params[:term]).length > 0
          Package.where(package_list: list).each do |package|
            @available_packages += [{label: formatted_date + '/' + package.order.to_s, value: package.id}]
          end
        end
      end
      render json: @available_packages.sort
    end

    def days_off
      @point = Point.find(params[:point_id])
      render json: @point.get_marked_days(params[:start_date])
    end

    def switch_day_off
      @point = Point.find(params[:point_id])
      date = Date.parse params[:date]
      @package_list = @point.package_lists.where(date: date).first
      if @package_list.day_off?
        @package_list.is_day_off = false
      else
        @package_list.is_day_off = true
      end
      respond_to do |format|
        if @package_list.save
          format.js { render 'show' }
        end
      end
    end

    def change_limit
      @point = Point.find(params[:point_id])
      date = Date.parse params[:date]
      @package_list = @point.package_lists.where(date: date).first
      if params[:new_limit].present? and params[:new_limit].to_i >= @package_list.packages.count
        @package_list.update_attribute :package_limit, params[:new_limit]
      end
      render json: @package_list.package_limit
    end

  end
end