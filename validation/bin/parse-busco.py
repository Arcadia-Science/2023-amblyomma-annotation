#! /usr/bin/env python3

import os
import re
import argparse
import pandas as pd

def main(input_dir, output_file):
    # Initialize a DataFrame to store the extracted data
    df = pd.DataFrame()

    # Regular expression pattern to match lines containing numbers before whitespace
    pattern = re.compile(r'^(\d+(\.\d+)?)[\s]+(.+)$')

    # Loop through each file in the directory
    for filename in os.listdir(input_dir):
        if filename.endswith(".txt"):
            # Extract the species name from the file name
            species_name = re.sub(r'^short_summary\.specific\.arachnida_odb10\.|\.\w+$', '', filename)

            # Initialize a dictionary to store the extracted data for this file
            data_dict = {'species_name': [species_name]}

            # Open the input file
            with open(os.path.join(input_dir, filename), 'r') as file:
                capture_data = False
                for line in file:
                    line = line.strip()

                    # Check if the line contains '***** Results: *****' to start capturing data
                    if line.startswith('***** Results: *****'):
                        capture_data = True
                        continue

                    # Stop capturing data when 'Dependencies and versions:' is encountered
                    if line.startswith('Dependencies and versions:'):
                        break

                    # Capture data lines
                    if capture_data:
                        match = pattern.match(line)
                        if match:
                            value = match.group(1)
                            description = match.group(3)

                            # Map the descriptions to the desired column names
                            column_names = {
                                "Complete BUSCOs (C)": "complete",
                                "Complete and single-copy BUSCOs (S)": "single",
                                "Complete and duplicated BUSCOs (D)": "duplicated",
                                "Fragmented BUSCOs (F)": "fragmented",
                                "Missing BUSCOs (M)": "missing",
                                "Total BUSCO groups searched": "total"
                            }

                            # Add the data to the dictionary using the mapped column names
                            if description in column_names:
                                data_dict[column_names[description]] = [float(value)]

            # Create a DataFrame from the extracted data for this file
            file_df = pd.DataFrame(data_dict)

            # Concatenate the file DataFrame with the main DataFrame
            df = pd.concat([df, file_df], ignore_index=True)

    # Reorder the columns to have "species_name" as the first column
    df = df[["species_name", "complete", "single", "duplicated", "fragmented", "missing", "total"]]

    # Calculate the percentages for each column (excluding "total") and round to two significant figures
    percentage_columns = ["complete", "single", "duplicated", "fragmented", "missing"]
    df[percentage_columns] = df[percentage_columns].div(df["total"], axis=0) * 100
    df[percentage_columns] = df[percentage_columns].round(2)

    # Drop the "total" column
    df.drop(columns=["total"], inplace=True)

    # Save the final DataFrame to the output file
    df.to_csv(output_file, sep='\t', index=False)

    print(f"Data has been extracted and saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse BUSCO summary files in a directory and save the results to an output file.")
    parser.add_argument("input_dir", help="Path to the directory containing BUSCO summary files.")
    parser.add_argument("output_file", help="Path to the output TSV file.")
    args = parser.parse_args()
    main(args.input_dir, args.output_file)
