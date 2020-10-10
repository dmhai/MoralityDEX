using MoralityDexModel;
using System;
using System.Collections.Generic;
using System.Text;

namespace MoralityDexRepositories
{
    public class BaseRepository
    {
        public MoralityDEXEntities _entities;

        public BaseRepository(MoralityDEXEntities entities)
        {
            _entities = entities;
        }

        public int Save()
        {
            return _entities.SaveChanges();
        }
    }
}
