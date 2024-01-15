import streamlit as st
import threading
import smtplib
import time
import subprocess
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

st.title("File Downloader")

# User input for URL and output file name

url = st.text_input("Enter URL to download")
output_file = st.text_input("Enter output file name")
recipient = st.text_input("Enter your email address")

# Define your background job here
def run_job():
    # perform tasks here
    cmd = f'curl {url} -o {output_file} &'
    subprocess.run(cmd, shell=True)
    # time.sleep(10) # example wait time


# Function to send email notification
def send_email():
    email_address = "comgenomics2023team2@outlook.com"
    password = "comgenomicsTeam2@"



    #create a message
    message = MIMEMultipart()
    message['From'] = email_address
    message['To'] = recipient
    message['Subject'] = "Job Completed"
    message.attach(MIMEText("Your background job is complete!"))


    # Create SMTP session for sending the mail
    smtp_session = smtplib.SMTP('smtp.office365.com', 587)
    smtp_session.starttls()
    smtp_session.login(email_address, password)
    smtp_session.sendmail(email_address, recipient, message.as_string())
    smtp_session.quit()


# Create a thread to run the background job
if st.button("Download"): #only when user hit download button
    job_thread = threading.Thread(target=run_job)
    job_thread.start()

    # Display message to user
    st.write("Your background job is running.")

    # Wait until job is finished
    while job_thread.is_alive():
        time.sleep(1)

    # Send email notification when job is complete
    send_email()
    st.write("Your background job is complete. An email has been sent to notify you.")
