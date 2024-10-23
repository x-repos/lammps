using CSV, DataFrames

# Reading the text file assuming it's space-delimited
df = CSV.File("dataSiO2-1.dat", delim=' ', ignorerepeated=true, header=false) |> DataFrame
@show size(df)
# Display the first few rows
first(df, 5)

# Choose around 10_000 particles based on the original size of 20_000
d = ∛(1/2) * maximum(df.Column4)
filter!(row -> row.Column4 <= d && row.Column5 <= d && row.Column6 <= d, df)

delete!(df, nrow(df))

# Assign the particle types
# 1431 is the unit of each type NaO-LiO-SiO2
# Int(10017/7) = 1431
df.Column2[1:1431*2]          .= 1
df.Column2[1431*2:1431*3]     .= 2
df.Column2[1431*3:end]      .= 3
# Charges
df.Column3[1:1431*2]          .= 1.2
df.Column3[1431*2:1431*3]     .= 2.4
df.Column3[1431*3:end]      .= -1.2
df

select!(df, Not([:Column1]))
df.Row = 1:nrow(df)

df = select(df, :Row, Not(:Row))
CSV.write("data-3.tsv", df, delim='\t')

maximum(df.Column4)
maximum(df.Column5)
maximum(df.Column6)
