package common;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectDB {
	public static Connection dbConn;

	public static Connection getConnection() {
		Connection conn = null;
		try {
			String user = "hr"; // 아이디
			String pw = "hr";// 비번
			String url = "jdbc:oracle:thin:@localhost:1521:xe"; // 오라클에 접속하기 위한 주소

			Class.forName("oracle.jdbc.driver.OracleDriver");
			conn = DriverManager.getConnection(url, user, pw);

			System.out.println("Database에 연결되었습니다.\n");

			// 예외 처리
		} catch (ClassNotFoundException cnfe) {
			System.out.println("DB 드라이버 로딩 실패 :" + cnfe.toString());
		} catch (SQLException sqle) {
			System.out.println("DB 접속실패 : " + sqle.toString());
		} catch (Exception e) {
			System.out.println("Unkonwn error");
			e.printStackTrace();
		}
		return conn;
	}

}