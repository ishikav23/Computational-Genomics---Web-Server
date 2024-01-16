#!/usr/bin/env python3
import streamlit as st
from PIL import Image
from pathlib import Path

st.markdown("# Team 2 Webserver")
st.markdown("### Computational Genomics 2023")
st.write("---")

st.title('About the pipeline')


st.subheader("User Input")
st.markdown("You will have to upload **two fastq files**")

st.subheader("Webserver Output")
st.markdown("In the output you will get a **Quast report** to visualize the quality of the input .fq files, a **distance tree** to see whether your sample clusters with an outbreak, and an **IG viewer** to vizualize your input sample's virulence factor and antibiotic resistance factor annotations.")

st.image('/home/projects/team2/app/Flowchart.png') #image of the workflow of the overall pipeline
st.caption("Summary of our pipeline (generated using miro)")


def read_markdown_file(markdown_file):
    return Path(markdown_file).read_text()

intro_markdown = read_markdown_file("/home/projects/team2/app/pages/Ishika.md")
st.markdown(intro_markdown, unsafe_allow_html=True)
