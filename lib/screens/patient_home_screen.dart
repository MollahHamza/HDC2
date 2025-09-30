// frontend/src/screens/ReportUploadScreen.js
import React, { useState, useEffect } from "react";
import axios from "axios";

const ReportUploadScreen = () => {
  const [file, setFile] = useState(null);
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Fetch uploaded reports
  const fetchReports = async () => {
    try {
      const token = localStorage.getItem("token");
      const { data } = await axios.get("http://localhost:8080/api/reports", {
        headers: { Authorization: `Bearer ${token}` },
      });
      setReports(data);
    } catch (err) {
      console.error(err);
      setError("Failed to load reports");
    }
  };

  useEffect(() => {
    fetchReports();
  }, []);

  // Upload new report
  const handleUpload = async (e) => {
    e.preventDefault();
    if (!file) {
      setError("Please select a file");
      return;
    }

    const formData = new FormData();
    formData.append("file", file);

    try {
      setLoading(true);
      setError("");

      const token = localStorage.getItem("token");
      await axios.post("http://localhost:8080/api/reports/upload", formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "multipart/form-data",
        },
      });

      setFile(null);
      await fetchReports(); // Refresh after upload
    } catch (err) {
      console.error(err);
      setError("Upload failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Upload Medical Report</h1>

      {error && <p className="text-red-500">{error}</p>}

      <form onSubmit={handleUpload} className="mb-6">
        <input
          type="file"
          onChange={(e) => setFile(e.target.files[0])}
          className="mb-2"
        />
        <button
          type="submit"
          disabled={loading}
          className="bg-blue-600 text-white px-4 py-2 rounded"
        >
          {loading ? "Uploading..." : "Upload"}
        </button>
      </form>

      <h2 className="text-xl font-semibold mb-2">Uploaded Reports</h2>
      {reports.length === 0 ? (
        <p>No reports uploaded yet.</p>
      ) : (
        <ul className="list-disc pl-5">
          {reports.map((report) => (
            <li key={report.id} className="mb-1">
              <a
                href={`http://localhost:8080/api/reports/download/${report.id}`}
                className="text-blue-500 underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                {report.filename}
              </a>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default ReportUploadScreen;
