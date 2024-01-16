#!/usr/bin/env python3

import streamlit as st
import streamlit.components.v1 as components 
import sys

st.markdown("# Team 2 Webserver")
st.markdown("### Computational Genomics 2023")
st.write("---")
st.header("Results")



# takes jobID from the job_tracking  
jobIDs = open("job_tracking.txt", 'r')

job_id = st.text_input(label="Enter job ID to display results", placeholder="00000000000")

for row in jobIDs:
	row = row.rstrip().split()
	if job_id == row[0]:
		results = f"/Users/Lindsey/Team2-Webserver/streamlit/jobs/{job_id}/output"
		## embedding the html page in the website

		st.write("Click to jump to section:")
		st.markdown("[Integrative Genome Viewer](#integrative-genome-viewer)")
		st.markdown("[Comparative Genomics](#comparative-genomics)")
		st.markdown("[Quast Report](#quast-quality-report)")


		st.header("Integrative Genome Viewer")

		with open(f"{results}/igv_out.html", 'r') as f:
			html_string = f.read() 
			components.html(html_string, width=900, height=900)



		st.write("---")
		st.header("Comparative Genomics")

		st.image(f"{results}/tree.png")
		st.caption("Distance tree")

		st.image(f"{results}/matrix_heatmap.png")
		st.caption("Heatmap of FastANI matrix")

		st.image(f"{results}/sample_heatmap.png")
		st.caption("Heatmap of samples clustered by ANI similarity")



		st.write("---")
		st.header("Quast Quality Report")
		with open(f"{results}/quast_report/report.html", 'r') as f:
			html_string = f.read() 
			components.html(html_string, width=1200, height=1500)

		with open(f"{results}/quast_report/icarus_viewers/contig_size_viewer.html") as f:
			html_string = f.read() 
			components.html(html_string, width=1200, height=500)
		
