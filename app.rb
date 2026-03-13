require 'sinatra'
require_relative './classes/Dbh.Class.rb'
require_relative './classes/UsersCntrl.Class.rb'
require_relative './classes/SchedulesCntrl.Class.rb'
require_relative './classes/SchedulesView.Class.rb'
require_relative './classes/ItemsCntrl.Class.rb'
require_relative './classes/ItemsView.Class.rb'
require_relative './classes/ReservedCntrl.Class.rb'
require_relative './classes/ReservationsView.Class.rb'
require_relative './classes/FilesCntrl.Class.rb'
require_relative './classes/FilesView.Class.rb'
require 'cgi'

# session management
enable :sessions

# Main IndexPage
get '/' do
  erb :index
end

## Process ##

# Sign in process
post '/login' do

  if params[:signinbtn]
    # Sanitize user inputs
    email = params[:signin_email].to_s.strip
    password = params[:signin_password].to_s.strip

    # Create user object
    signin_user = UsersCntrl.new()

    if signin_user.login_user(email, password, session)

      # Redirect to the dashboard page
      redirect '/dashboard'
    else
      # Redirect to the sign-in page
      redirect '/signin'
    end

  else
    # Redirect to the sign-in page with an error message
    redirect '/?error=invalid_access'
  end

end

# Sign up process
post '/register' do

  if params[:signupbtn]
    # Sanitize user inputs
    email = params[:signup_email].to_s.strip
    password = params[:signup_password].to_s.strip
    code = params[:signup_code].to_s.strip
    laboratory = params[:signup_laboratory].to_s.strip

    # Create user object
    signup_user = UsersCntrl.new(email, code, password, laboratory)

    if signup_user.register_user()

      # Redirect to the sign-in page upon successful registration
      session[:message] = "Registration successful!"
      redirect '/signin'
    else
      # Redirect to the sign-up page with an error message
      session[:message] = "Registration failed!"
      redirect '/signin'
    end

  else
    # Redirect to the sign-in page with an error message
    redirect '/?error=invalid_access'
  end
  
end

post '/add-schedule' do

  if params[:addschedulebtn]

    # Sanitize user inputs
    user_id = session[:user_id]
    teacher_name = params[:teacher_name].to_s.strip
    class_time = params[:class_time].to_s.strip
    lab_schedule = params[:lab_schedule].to_s.strip
    class_code = params[:class_code].to_s.strip
    classroom_number = params[:classroom].to_s.strip
    course = params[:course].to_s.strip
    status = params[:status].to_s.strip

    # Create schedule object
    schedule = SchedulesCntrl.new(user_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status)

    if schedule.add_schedule(session)
      session[:schedule_message] = "Schedule added successfully!"
      redirect '/schedule'
    else
      session[:schedule_message] = "Registration failed!"
      redirect '/schedule'
    end

  else
    redirect '/schedule?error=invalid_access'
  end

end

post '/update-schedule' do

  if params[:updateschedulebtn]

    # Sanitize user inputs
    schedule_id = params[:schedule_id].to_s.strip
    teacher_name = params[:teacher_name].to_s.strip
    class_time = params[:class_time].to_s.strip
    lab_schedule = params[:lab_schedule].to_s.strip
    class_code = params[:class_code].to_s.strip
    classroom_number = params[:classroom].to_s.strip
    course = params[:course].to_s.strip
    status = params[:status].to_s.strip

    # Create schedule object
    schedule = SchedulesCntrl.new()

    if schedule.update_schedule_data(schedule_id, teacher_name, class_time, lab_schedule, class_code, classroom_number, course, status, session)
      session[:schedule_message] = "Schedule updated successfully!"
      redirect '/schedule'
    else
      session[:schedule_message] = "Failed to update schedule!"
      redirect '/schedule'
    end

  else
    redirect '/schedule?error=invalid_access'
  end

end

post '/delete-schedule' do

  if params[:deleteschedulebtn]

    # Sanitize user inputs
    schedule_id = params[:schedule_id].to_s.strip

    # Create schedule object
    schedule = SchedulesCntrl.new()

    if schedule.remove_schedule(schedule_id, session)
      session[:schedule_message] = "Schedule deleted successfully!"
      redirect '/schedule'
    else
      session[:schedule_message] = "Failed to delete schedule! #{schedule_id}"
      redirect '/schedule'
    end

  else
    redirect '/schedule?error=invalid_access'
  end

end

post '/attendance' do

    # Sanitize user inputs
    schedule_id = params[:schedule_id].to_s.strip
    total_hours = params[:total_hours].to_s.strip

    if params[:presentbtn]
      status = "present"
    elsif params[:absentbtn]
      status = "absent"
    else
      redirect '/dashboard?error=invalid_status'
    end

    # Create schedule object
    schedule = SchedulesCntrl.new()

    if schedule.update_attendance(schedule_id, status, total_hours, session)
      session[:dashboard_message] = "Attendance updated successfully!"
      redirect '/dashboard'
    else
      session[:dashboard_message] = "Failed to update attendance!"
      redirect '/dashboard'
    end

end

## Inventory Management ##
post '/add-inventory' do
  if params[:addinventorybtn]
    # Sanitize user inputs
    name = params[:name].to_s.strip
    quantity = params[:quantity].to_i
    type = params[:type].to_s.strip

    # Handle file upload
    if params[:picture] && params[:picture][:filename] && params[:picture][:tempfile]
      filename = params[:picture][:filename]
      tempfile = params[:picture][:tempfile]

      # Create a unique filename to prevent conflicts
      unique_filename = "#{Time.now.to_i}_#{filename}"

      # Destination path
      save_path = File.join(settings.public_folder, 'items', unique_filename)

      # Save the file
      FileUtils.copy(tempfile.path, save_path)
    else
      unique_filename = nil
    end

    # Create items object
    items = ItemsCntrl.new(name, quantity, type, unique_filename)

    # Pass the saved filename, not the raw param
    if items.add_item(session)
      session[:inventory_message] = "Item added successfully!"
      redirect '/reservation'
    else
      session[:inventory_message] = "Failed to add item!"
      redirect '/reservation'
    end
  else
    redirect '/reservation?error=invalid_access'
  end
end

## Kiosk ##
get "/index" do
  erb :index
end
get '/signin' do
  erb :signin
end
get '/subjects' do
  erb :subjects
end

# Set user type
post '/set-user-type' do
  session[:user_type] = params[:user_type].to_s.strip
  redirect '/subjects'
end

get '/kiosk' do
  items_view = ItemsView.new
  @items = items_view.get_items() || []
  erb :kiosk
end

# reserve items
post '/reserve-items' do
  # Capture reservation data
  name = params[:name].to_s.strip
  type = session[:user_type].to_s.strip
  date_of_use = params[:date_of_use].to_s.strip
  class_code = params[:class_code].to_s.strip
  course_title = params[:course_title].to_s.strip
  program = params[:program].to_s.strip

  # Capture cart items
  cart = []
  if params[:cart]
    params[:cart].each do |index, item_data|
      cart << {
        id: item_data[:id].to_s.strip,
        qty: item_data[:qty].to_i
      }
    end
  end

  # Create reservation object and process
  reservation = ReservedCntrl.new(name, type, date_of_use, class_code, course_title, program, cart)

  if reservation.add_reservation(session)
    redirect '/kiosk'
  else
    redirect '/kiosk'
  end
end

# Update cart item status (approve/reject/return)
post '/update-cart-status' do
  cart_id = params[:cart_id].to_i
  status = params[:status].to_s.strip

  reservedcntrl = ReservedCntrl.new
  if reservedcntrl.update_cart_status(cart_id, status)
    session[:status_message] = "Status updated successfully!"
  else
    session[:status_message] = "Failed to update status"
  end

  redirect '/reservation'
end

# Update all items for a reservation
post '/update-reservation-status' do
  reservation_id = params[:reservation_id].to_i
  status = params[:status].to_s.strip

  reservedcntrl = ReservedCntrl.new
  if reservedcntrl.update_reservation_status(reservation_id, status)
    session[:status_message] = "All items status updated successfully!"
  else
    session[:status_message] = "Failed to update status"
  end

  redirect '/reservation'
end

post '/update-inventory' do
  items = ItemsCntrl.new

  inventory_id = params[:inventory_id].to_i
  name = params[:name].to_s.strip
  quantity = params[:quantity].to_i
  type = params[:type].to_s.strip

  # Handle file upload
  uploaded_file = params[:picture]
  existing_picture = params[:existing_picture] # hidden input in form

  if uploaded_file && uploaded_file[:filename] && uploaded_file[:tempfile]
    # Save new uploaded file
    filename = "#{Time.now.to_i}_#{uploaded_file[:filename]}"
    save_path = File.join(settings.public_folder, 'items', filename)

    File.open(save_path, 'wb') { |f| f.write(uploaded_file[:tempfile].read) }

    picture_to_save = filename
  else
    # No new file uploaded, keep existing picture
    picture_to_save = existing_picture
  end

  # Update inventory
  if items.update_item(inventory_id, name, quantity, type, picture_to_save, session)
    session[:inventory_message] = "Inventory updated successfully!"
  else
    session[:inventory_message] = "Failed to update inventory."
  end

  redirect '/reservation'
end

# Delete inventory item
post '/delete-inventory' do
  inventory_id = params[:inventory_id].to_i
  items = ItemsCntrl.new

  if items.delete_item(inventory_id, session)
    session[:inventory_message] = "Item deleted successfully!"
  else
    session[:inventory_message] = "Failed to delete item!"
  end

  redirect '/reservation'
end

# Add Excel file
post '/add-excel' do
  # Sanitize form inputs
  prof_name    = params[:prof_name].to_s.strip
  course_code  = params[:course_code].to_s.strip
  course_title = params[:course_title].to_s.strip

  # Get uploaded file
  uploaded_file = params[:excel_file]

  if uploaded_file && uploaded_file[:filename] && uploaded_file[:tempfile]
    # Make a unique filename to prevent collisions
    timestamp = Time.now.to_i
    filename = "#{timestamp}_#{uploaded_file[:filename]}"

    # Destination path in /public/files
    save_path = File.join(settings.public_folder, 'files', filename)

    # Ensure the directory exists
    FileUtils.mkdir_p(File.dirname(save_path))

    # Save the file to disk
    File.open(save_path, 'wb') do |f|
      f.write(uploaded_file[:tempfile].read)
    end

    # Insert record into database using FilesCntrl
    files_ctrl = FilesCntrl.new(prof_name, course_code, course_title, filename)
    if files_ctrl.add_file(session)
      session[:student_message] = "File uploaded and saved successfully!"
    else
      session[:student_message] = "File uploaded but failed to save to database!"
    end

  else
    session[:student_message] = "No file selected or invalid file!"
  end

  redirect '/students'
end

## Sidebar Headers ##
get "/dashboard" do
  if session[:email].nil?
    return erb :signin
  end
  schedule_view = SchedulesView.new
  @schedules = schedule_view.get_schedules()
  erb :dashboard
end
get "/reservation" do
  if session[:email].nil?
    return erb :signin
  end
  items_view = ItemsView.new
  @items = items_view.get_items() || []

  reservations_view = ReservationsView.new
  @reservations = reservations_view.show_reservations() || []

  erb :reservation
end
get "/schedule" do
  if session[:email].nil?
    return erb :signin
  end
  schedule_view = SchedulesView.new
  @schedules = schedule_view.get_schedules()

  erb :"schedule"

end
get "/students" do
  if session[:email].nil?
    return erb :signin
  end
  files_view = FilesView.new
  @files = files_view.get_files()
  erb :students
end
get "/logout" do
  session.clear
  redirect "/signin"
end
