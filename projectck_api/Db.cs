using Microsoft.Data.SqlClient;

namespace ProjectckApi;

public class Db(string connectionString)
{
    public SqlConnection Open()
    {
        var connection = new SqlConnection(connectionString);
        connection.Open();
        return connection;
    }

    public static SqlCommand Command(SqlConnection connection, string sql,
        object? args = null, SqlTransaction? transaction = null)
    {
        var command = new SqlCommand(sql, connection, transaction);
        if (args != null)
        {
            foreach (var property in args.GetType().GetProperties())
            {
                command.Parameters.AddWithValue("@" + property.Name, property.GetValue(args) ?? DBNull.Value);
            }
        }
        return command;
    }

    public List<Dictionary<string, object?>> Query(string sql, object? args = null)
    {
        using var connection = Open();
        using var reader = Command(connection, sql, args).ExecuteReader();
        var rows = new List<Dictionary<string, object?>>();
        while (reader.Read())
        {
            var row = new Dictionary<string, object?>();
            for (var i = 0; i < reader.FieldCount; i++)
            {
                row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
            }
            rows.Add(row);
        }
        return rows;
    }

    public Dictionary<string, object?>? QueryOne(string sql, object? args = null) =>
        Query(sql, args).FirstOrDefault();

    public object? Scalar(string sql, object? args = null)
    {
        using var connection = Open();
        var value = Command(connection, sql, args).ExecuteScalar();
        return value == DBNull.Value ? null : value;
    }

    public int Execute(string sql, object? args = null)
    {
        using var connection = Open();
        return Command(connection, sql, args).ExecuteNonQuery();
    }
}
