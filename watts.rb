# Require the necessary libraries (gems)
require 'csv'

# Creates an array with the given "range", and in steps of "step"
def get_all_steps range, step
    values = []
    value = range.first
    while value <= range.last
        values.push value
        value += step
    end
    return values
end

# Writes the given "field" informations into a filename.csv file
def csv_write filename , *field
    CSV.open(filename, "a") do |csv|
        csv << field
    end
end

# Traverses all possible combinations of material & dimensions of the Watts Arm, to find out the optimal case
def bruteforce
    File.delete("Optimals.csv") if File.exists? "Optimals.csv"
    csv_write("Optimals.csv","Material","#{L_RANGE[0]} < L < #{L_RANGE[1]} (in m)","#{D_RANGE[0]} < D < #{D_RANGE[1]} (in m)","#{P_RANGE[0]} < P_allowable < #{P_RANGE[1]} (in kN)","Max. objective = P_allowable / Volume = P/(D*D*L)")   
    MATERIALS.each do |mat|
        filename = "#{mat[:name]}.csv"
        File.delete(filename) if File.exists? filename
        csv_write(filename,"#{L_RANGE[0]} < L < #{L_RANGE[1]} (in m)","#{D_RANGE[0]} < D < #{D_RANGE[1]} (in m)","#{P_RANGE[0]} < P_allowable < #{P_RANGE[1]} (in kN)","Max. objective = P_allowable / Volume = P/(D*D*L)")   
        e = mat[:value]
        data = []
        get_all_steps(L_RANGE,L_STEP).each do |l| # Loop through length
            get_all_steps(D_RANGE,D_STEP).each do |d| # Loop through diameter
                p = (3.14*3.14*3.14*e*d*d*d*d)/(64*l*l*5) # Apply formula for load
                obj = p/(l*d*d) # Objective function to be maximized
                data.push({e: e,l: l,d: d,p: p,obj: obj})
                csv_write(filename,l,d,p,obj)
            end
        end 
        
        # Find the optimal case
        data = data.sort_by { |x| x[:obj] }.reverse

        # Check if obtained solution of load is feasible
        while data[0][:p] < P_RANGE[0] || data[0][:p] > P_RANGE[1] 
            data.delete_at 0
        end
        csv_write("Optimals.csv",mat[:name],data[0][:l],data[0][:d],data[0][:p],data[0][:obj])
        puts data[0]
    end
end

# Initialize the constants
P_RANGE = [5.49*1000,27.13*1000]
L_RANGE = [200.0/1000.0,250.0/1000.0]
D_RANGE = [15.0/1000.0,20.0/1000.0]
L_STEP = 1.0/1000.0
D_STEP = 0.1/1000.0
MATERIALS = [{name: "Aluminium",value: 70.0*1000000000},{name: "Carbon_Steel_Alloy",value: 203.0*1000000000}]

# Perform the bruteforce
bruteforce()