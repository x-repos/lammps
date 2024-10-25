using CSV, DataFrames
using Statistics
using GLMakie

# Reading the text file assuming it's space-delimited
df = CSV.File("coordinate.txt", delim=' ', ignorerepeated=true, header=false) |> DataFrame
@show size(df)
# Display the first few rows
first(df, 5)

type = df.Column1
x = df.Column2
y = df.Column3
z = df.Column4



num_ones1 = count(==(1), df[:, 1])
num_ones2 = count(==(2), df[:, 1])
num_ones3 = count(==(3), df[:, 1])
num_ones1 + num_ones2 + num_ones3


xsi = x[2862:2862+1431]
xo = x[2862+1431+1:end]
ysi = y[2862:2862+1431]
yo = y[2862+1431+1:end]
zsi = z[2862:2862+1431]
zo = z[2862+1431+1:end]

lx = maximum(x)
ly = maximum(y)
lz = maximum(z)

function dist(x1, y1, z1, x2, y2, z2, lx, ly, lz)
    rx = x1 - x2
    if rx > lx / 2
        rx -= lx
    elseif rx < -lx / 2
        rx += lx
    end

    ry = y1 - y2
    if ry > ly / 2
        ry -= ly
    elseif ry < -ly / 2
        ry += ly
    end

    rz = z1 - z2
    if rz > lz / 2
        rz -= lz
    elseif rz < -lz / 2
        rz += lz
    end

    return sqrt(rx^2 + ry^2 + rz^2)
end

# Define the cutoff distance (you can adjust this value)
cutoff_distance = 3.5  # Change this value based on your needs

# Initialize an array to store the coordination numbers
coordination_numbers = []

# Loop through each silicon atom
for i in 1:nrow(df)
    if type[i] == 1  # Assuming 1 represents Si
        count = 0
        # Loop through each atom to find oxygen neighbors
        for j in 1:nrow(df)
            if type[j] == 3  # Assuming 2 represents O
                d = dist(x[i], y[i], z[i], x[j], y[j], z[j], lx, ly, lz)
                if d < cutoff_distance
                    count += 1
                end
            end
        end
        push!(coordination_numbers, count)
    end
end

# Compute the average coordination number
average_coordination_number = mean(coordination_numbers)

coordination_numbers


GLMakie.activate!()

aspect=(1, 1, 1)
perspectiveness=0.5
# the figure
fig = Figure(; size=(600, 600))
ax2 = Axis3(fig[1, 1]; aspect, perspectiveness)
meshscatter!(ax2, x, y, z; markersize=type/2, color=type)

fig


# Parameters for RDF calculation
cutoff_distance = 10.0  # Adjust this as necessary
num_bins = 1200          # Number of bins
bin_width = cutoff_distance / num_bins
radii = [i * bin_width for i in 1:num_bins]  # Bin centers
g_r = zeros(num_bins)  # Array to hold RDF values

# Count pairs of Si (type 2) and O (type 3) atoms
num_si = count(==(1), type)  # Count Si atoms
num_o = count(==(3), type)   # Count O atoms

# Loop through each silicon atom
# Loop through each silicon atom
for i in 1:nrow(df)
    if type[i] == 1  # If it's a silicon atom
        for j in 1:nrow(df)
            if type[j] == 3  # If it's an oxygen atom
                d = dist(x[i], y[i], z[i], x[j], y[j], z[j], lx, ly, lz)
                if d < cutoff_distance
                    bin_index = floor(Int, d / bin_width) + 1  # Use floor to avoid InexactError
                    if bin_index <= num_bins  # Increment the count in the appropriate bin
                        g_r[bin_index] += 1
                    end
                end
            end  # End for oxygen atom
        end  # End for all atoms
    end  # End for silicon atom
end  # End for all silicon atoms

# Normalize the RDF
volume = (4/3) * π * ((radii .+ bin_width).^3 .- radii.^3)  # Volume of the spherical shell for each bin
g_r .= g_r ./ (num_si * num_o * volume)  # Normalize by the number of Si and O atoms and volume

# Optionally, you might want to average over the total number of Si atoms
g_r .= g_r ./ num_si  # Average per Si atom

# Display RDF results
@show g_r

# lines(radii, g_r)

# Create a figure and axis
fig = Figure(size=(800, 600))
ax = Axis(fig[1, 1], title="Radial Distribution Function (RDF) for Si-O",
          xlabel="Distance (r)", ylabel="g(r)", 
          xticks=0:0.1:10,  # More x-ticks from 0 to 10 with a step of 0.5
          yticks=0:0.5:3)   # Custom y-ticks from 0 to 3 with a step of 0.5

# Plot the RDF
lines!(ax, radii, g_r, color=:blue, linewidth=2, label="RDF")

# Display the figure
display(fig)



## plots the progress
using CSV, DataFrames
GLMakie.activate!()
# Reading the text file assuming it's space-delimited
df = CSV.read("log.txt", DataFrame; delim=' ', ignorerepeated=true)

# Display the first few rows
first(df, 10)
fig = Figure(size=(1000, 1000))

ax1 = Axis(fig[1,1], ylabel=L"\text{Temp}", xlabel=L"\text{Step}\times 1000")
ax2 = Axis(fig[2,1], ylabel=L"\text{Press}", xlabel=L"\text{Step}\times 1000")
ax3 = Axis(fig[3,1], ylabel=L"\text{Volume}", xlabel=L"\text{Step}\times 1000")
ax4 = Axis(fig[4,1], ylabel=L"\text{Density}", xlabel=L"\text{Step}\times 1000")
ax5 = Axis(fig[1,2], ylabel=L"\text{TotEng}", xlabel=L"\text{Step}\times 1000")
ax6 = Axis(fig[2,2], ylabel=L"\text{PotEng}", xlabel=L"\text{Step}\times 1000")
ax7 = Axis(fig[3,2], ylabel=L"\text{KinEng}", xlabel=L"\text{Step}\times 1000")

lines!(ax1,df.Temp[1000:end])
lines!(ax2,df.Press[1000:end])
lines!(ax3,df.Volume[1000:end])
lines!(ax4,df.Density[1000:end])
lines!(ax5,df.TotEng[1000:end])
lines!(ax6,df.PotEng[1000:end])
lines!(ax7,df.KinEng[1000:end])