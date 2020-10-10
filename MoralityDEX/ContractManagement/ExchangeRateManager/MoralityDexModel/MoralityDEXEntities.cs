using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MoralityDexModel.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexModel
{
    public partial class MoralityDEXEntities : DbContext
    {
        public virtual DbSet<Token> Tokens { get; set; }
        public virtual DbSet<Transaction> Transactions { get; set; }

        private string _databaseConnectionString;
        private string _migrationsAssembly;
        private string _schemaName = "dex";

        public MoralityDEXEntities(DbContextOptions<MoralityDEXEntities> options) : base(options)
        { }

        public MoralityDEXEntities(MoralityDEXSettings applicationSettings)
        {
            _databaseConnectionString = applicationSettings.LocalDatabaseConnectionString;
            _migrationsAssembly = applicationSettings.MigrationsAssembly;
        }

        public MoralityDEXEntities(IOptions<MoralityDEXSettings> applicationSettings, DbContextOptions<MoralityDEXEntities> options)
            : base(options)
        {
            _databaseConnectionString = applicationSettings?.Value.LocalDatabaseConnectionString;
            _migrationsAssembly = applicationSettings?.Value.MigrationsAssembly;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer(
                   _databaseConnectionString,
                    b => b.MigrationsAssembly(_migrationsAssembly)
                );
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder = SetupNamesAndSchema(modelBuilder);
            modelBuilder = SetupProperties(modelBuilder);
        }

        private ModelBuilder SetupNamesAndSchema(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Token>().ToTable("Tokens", _schemaName);
            modelBuilder.Entity<Transaction>().ToTable("Transactions", _schemaName);
            return modelBuilder;
        }

        private ModelBuilder SetupProperties(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Token>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.PointPrecision).ValueGeneratedOnAdd();
                entity.Property(e => e.Active).ValueGeneratedOnAdd();
                entity.Property(e => e.Symbol).IsRequired();
            });

            modelBuilder.Entity<Transaction>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.RequestAddress).IsRequired();
                entity.Property(e => e.Symbol).IsRequired();
                entity.Property(e => e.TokenAddress).IsRequired();
                entity.Property(e => e.Rate).IsRequired();
                entity.Property(e => e.Tx).IsRequired();
            });

            return modelBuilder;
        }
    }
}
