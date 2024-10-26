using CSV, DataFrames

# Reading the text file assuming it's space-delimited
df = CSV.File("dataSiO2-1.dat", delim=' ',
            ignorerepeated=true, header=false) |> DataFrame
# Display the first few rows
first(df, 5)

# Choose around 10_000 particles based on the original size of 20_000
d = ∛(1/2) * maximum(df.Column4)
d = d-0.02
filter!(row -> row.Column4 <= d
        && row.Column5 <= d
        && row.Column6 <= d, df)
delete!(df, nrow(df) - 6 + 1 : nrow(df))

nunit = Int(size(df)[1]/9) # Na20-Li20-SiO2 => 9
nna, nli, nsi, noxy = 2, 2, 1, 4
# update types
Na = fill(1, nunit*nna)
Li = fill(2, nunit*nli)
Si = fill(3, nunit*nsi)
Oxy = fill(4, nunit*noxy)
df.Column2 = vcat(Na, Li, Si, Oxy)
df

# upate charges
Na = fill(0.6, nunit*nna)
Li = fill(0.6, nunit*nli)
Si = fill(2.4, nunit*nsi)
Oxy = fill(-1.2, nunit*noxy)
df.Column3 = vcat(Na, Li, Si, Oxy)
df

# update order
select!(df, Not([:Column1]))
df.Row = 1:nrow(df)

df = select(df, :Row, Not(:Row))
CSV.write("data-3.tsv", df, delim='\t')

maximum(df.Column4)
maximum(df.Column5)
maximum(df.Column6)
